package snake.util;

import sys.thread.Mutex;
import sys.thread.Thread;
import sys.thread.Lock;

class ThreadPool {
	public var maxThreads:Int;
	private var queue:Array<() -> Void>;
	private var queueLock:Mutex;
	private var queueSignal:Lock;
	private var running:Bool = true;

	public function new(maxThreads:Int) {
		this.maxThreads = maxThreads;
		this.queue = [];
		this.queueLock = new Mutex();
		this.queueSignal = new Lock();

		for (i in 0...maxThreads) {
			Thread.create(workerLoop);
		}
	}

	public function submit(task:() -> Void):Void {
		queueLock.acquire();
		queue.push(task);
		queueLock.release();
		queueSignal.release(); // wake a worker
	}

	private function workerLoop():Void {
		while (running) {
			var task:() -> Void = null;

			// get a task from the queue
			queueLock.acquire();
			if (queue.length > 0) {
				task = queue.shift();
			}
			queueLock.release();

			if (task != null) {
				try {
					task();
				} catch (e:Dynamic) {
					trace("ThreadPool: task failed " + e);
				}
			} else {
				// wait for new task signal
				queueSignal.wait();
			}
		}
	}

	public function shutdown():Void {
		running = false;
		// Wake all threads so they can exit
		for (i in 0...maxThreads) {
			queueSignal.release();
		}
	}
}

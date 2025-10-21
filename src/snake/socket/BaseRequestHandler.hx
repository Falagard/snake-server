package snake.socket;

import sys.net.Host;
import sys.net.Socket;
import haxe.Exception;

/**
	Base class for request handler classes.
**/
class BaseRequestHandler {
	private var request:Socket;
	private var clientAddress:{host:Host, port:Int};
	private var server:BaseServer;

	/**
		Constructor.
	**/
	public function new(request:Socket, clientAddress:{host:Host, port:Int}, server:BaseServer) {
		this.request = request;
		this.clientAddress = clientAddress;
		this.server = server;
	}

	// instead of running this in the constructor, we have a separate method which returns a Future

	public function processRequest()  {
		
            trace("processRequest called at " + Sys.time() );
			setup();
            trace("processRequest setup completed at " + Sys.time() );
			try {
				handle();
                trace("processRequest handle completed at " + Sys.time() );
			} catch (e:Exception) {
				finish();
				throw e;
			}
			finish();

	}

	private function setup():Void {}

	private function handle():Void {}

	private function finish():Void {}
}

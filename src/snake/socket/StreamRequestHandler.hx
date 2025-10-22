package snake.socket;

import sys.net.Host;
import haxe.Exception;
import haxe.io.Output;
import sys.net.Socket;
import haxe.io.Input;

/**
	Define `rfile` and `wfile` for stream sockets.
**/
class StreamRequestHandler extends BaseRequestHandler {
	/**
		A timeout to apply to the request socket, if not `null`.
	**/
	public var timeout:Null<Float> = null;

	/**
		Disable nagle algorithm for this socket, if `true`.
		Use only when wbufsize != 0, to avoid small packets.
	**/
	public var disableNagleAlgorithm:Bool = false;

	private var connection:Socket;
	private var rfile:Input;
	private var wfile:Output;

	/**
		Constructor.
	**/
	public function new(request:Socket, clientAddress:{host:Host, port:Int}, server:BaseServer) {
		super(request, clientAddress, server);
	}

	override private function setup():Void {
		connection = cast(request, Socket);
		if (disableNagleAlgorithm) {
			connection.setFastSend(true);
		}
		if (timeout != null) {
			connection.setTimeout(timeout);
		}
		rfile = connection.input;
		wfile = connection.output;
	}

	override private function finish():Void {
		try {
			wfile.flush();
		} catch (e:Exception) {
			// A final socket error may have occurred here, such as
			// the local error ECONNABORTED.
            trace('Error flushing socket output: ${e}');
		}
        //Clay - removed connection.close since it is handled by TcpServer
        //connection.close();
	}
}

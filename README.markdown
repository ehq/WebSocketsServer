Web Sockets Server
==================

This is an initial draft for a very light weight web sockets server. I'm currently using this on a production environment and it's working great. My goal now is to extract this code into a lib, add tests and package it into a gem.

Any contributions are welcome, both in code and ideas/suggestions/requests.

Usage
=====

Require the libs and use them to initialize a web sockets server.

    require "web_socket"
    require "web_socket_server"

    class ChatServer
      attr_accessor :ws_server

      def initialize
        @ws_server = WebSocketServer.new(:port => 8080)
      end

      def run!
        ws_server.run do |ws|
          ws.handshake # Initialize the connection

          while message = ws.receive # Process incoming messages
            process_message(message)
          end

          close_connection(message, ws)
        end
      end

MIT License
===========

Copyright (C) 2011 by Lucas Nasif  nasif.lucas@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

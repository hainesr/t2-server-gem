# Copyright (c) 2010, 2011 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
#  * Neither the names of The University of Manchester nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Author: Robert Haines

require 'net/http'

module T2Server
  # :stopdoc:
  # An internal module to collect all the exceptions that we
  # can't really do anything about ourselves, such as
  # timeouts and lost connections. This is further wrapped
  # and exposed in the API as T2Server::ConnectionError below.
  module InternalHTTPError
  end

  # These are the HTTP errors we want to catch.
  # Add the above exception as an ancestor to them all.
  [
    EOFError,
    SocketError,
    Timeout::Error,
    Errno::EINVAL,
    Errno::ETIMEDOUT,
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError
  ].each {|err| err.send(:include, InternalHTTPError)}

  # :startdoc:
  # This is a superclass for all T2Server exceptions. It is provided as a
  # useful catch-all for all the internally raised/thrown exceptions.
  class T2ServerError < RuntimeError
  end

  # Raised when there is an error with the connection to the server in some
  # way. This could be due to the server not accepting the connection, the
  # connection being dropped unexpectedly or a timeout of some sort.
  class ConnectionError < T2ServerError
    attr_reader :cause

    # Create a new ConnectionError with the specified cause. The cause to be
    # passed in should be the exception object that caused the connection
    # error.
    def initialize(cause)
      @cause = cause
      super "Connection error (#{@cause.class.name}): #{@cause.message}"
    end
  end

  # Raised when there is an unexpected response from the server. This does
  # not necessarily indicate a problem with the server.
  class UnexpectedServerResponse < T2ServerError

    # Create a new UnexpectedServerResponse with the specified unexpected
    # response. The response to be passed in is that which was returned by a
    # call to Net::HTTP#request.
    def initialize(response)
      body = "\n#{response.body}" if response.body
      super "Unexpected server response: #{response.code}\n#{response.error!}#{body}"
    end
  end

  # Raised when the run that is being operated on cannot be found. If the
  # expectation is that the run exists then it could have been destroyed by
  # a timeout or another user.
  class RunNotFoundError < T2ServerError
    attr_reader :uuid

    # Create a new RunNotFoundError with the specified UUID.
    def initialize(uuid)
      @uuid = uuid
      super "Could not find run #{@uuid}"
    end
  end

  # Indicates that the attribute that the user is trying to read/change does
  # not exist. The attribute could be a server or run attribute.
  class AttributeNotFoundError < T2ServerError
    attr_reader :path

    # Create a new AttributeNotFoundError with the path to the erroneous
    # attribute.
    def initialize(path)
      @path = path
      super "Could not find attribute at #{@path}"
    end
  end

  # The server is at capacity and cannot accept anymore runs at this time.
  class ServerAtCapacityError < T2ServerError
    attr_reader :limit

    # Create a new ServerAtCapacityError with the specified limit for
    # information.
    def initialize(limit)
      @limit = limit
      super "The server is already running its configured limit of concurrent workflows (#{@limit})"
    end
  end

  # Access to the entity (run or attribute) is denied. The credentials
  # supplied are not sufficient or the server does not allow the operation.
  class AccessForbiddenError < T2ServerError
    attr_reader :path

    # Create a new AccessForbiddenError with the path to the restricted
    # attribute.
    def initialize(path)
      @path = path
      super "Access to #{@path} is forbidden. Either you do not have the required credentials or the server does not allow the requested operation"
    end
  end

  # Access to the server is denied to this username
  class AuthorizationError < T2ServerError
    attr_reader :username

    # Create a new AuthorizationError with the rejected username
    def initialize(username)
      @username = username
      super "The username '#{@username}' is not authorized to connect to this server"
    end
  end

  # Raised if an operation is performed on a run when it is in the wrong
  # state. Trying to start a run if it is the finished state would cause this
  # exception to be raised.
  class RunStateError < T2ServerError

    # Create a new RunStateError specifying both the current state and that
    # which is needed to run the operation.
    def initialize(current, need)
      super "The run is in the wrong state (#{current}); it should be '#{need}' to perform that action"
    end
  end
end

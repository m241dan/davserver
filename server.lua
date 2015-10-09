local socket = require( "socket" )
local Client = require( "client" )

local S = {}

---------------------------------------------
-- Server Functions
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------

function acceptNewConnection( server )
end

function readFromClients( server )
end

---------------------------------------------
-- Server Methods                          --
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------

function S:new( port )
   local server = {}

   setmetatable( server, self )
   self.__index = self;

   server.socket = assert( socket.tcp(), "could not allocate new tcp socket" )
   assert( server.socket:bind( "*", port ), "could not bind to port" )
   server.socket:listen()
   server.socket:setoption( 'reuseaddr', true )
   server.socket:settimeout(0)
   server.connections = {}
   server.accepting = false

   return server;
end

function S:accept()
   local connection, err = self.socket:accept()
   local ipthr, client
   if( not err ) then
      if( self.accepting == true ) then
         ipthr, client = Client:new( connection )
         self.connections[#self.connections+1] = client
         connection:send( "You have connected..." )
      else
         connection:send( "We are not currently accepting connections." )
         connection:close()
      end
   end
   return ipthr, client
end	

function S:poll()

end

function S:push()
end

function S:start()
   self.accepting = true
   return self.athread
end

function S:stop()
   self.accepting = false
end

return S

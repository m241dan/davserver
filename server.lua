local socket = require( "socket" )
local Client = require( "client" )

local S = {}

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
   server.new_connections = {}
   server.accepting = false

   return server;
end

function S:accept()
   local connection, err = self.socket:accept()
   local client
   if( not err ) then
      if( self.accepting == true ) then
         client = Client:new( connection )
         if( not client ) then return; end
         self:addClient( client )
      else
         connection:send( "We are not currently accepting connections.\n" )
         connection:close()
      end
   end
   return client
end	

function S:poll()
   for i, client in ipairs( self.new_connections ) do
      client.addr, client.port, client.net = client.connection:getsockname()
      if( client.addr ~= nil ) then
         table.remove( self.new_connections, i )
      end
   end

   for i, client in ipairs( self.connections ) do
      if( client:receive() == false ) then
         table.remove( self.connections, i )
      end
   end
end

function S:push()
   for _, client in ipairs( self.connections ) do
      client:send()
   end
end

function S:start()
   self.accepting = true
end

function S:stop()
   self.accepting = false
end

function S:addClient( client )
   self.connections[#self.connections+1] = client
   self.new_connections[#self.new_connections+1] = client
   client.connection:send( "You have connected...\n" )
end

function S:close()
   for i, client in ipairs( self.connections ) do
      client:close()
   end
   self.socket:close()
   self.connections = {}
   self.new_connections = {}
end

return S


local socket = require( "socket" )
local EventQueue = require( "libs/eventqueue" )
local Client = require( "objects/client" )
local S = {}

---------------------------------------------
-- Server Coroutines                       --
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------

local function acceptNewConnection( server )
   while true do
      local connection, err = server.socket:accept()
      if( not err ) then
         if( server.accepting == true ) then
            local new_client = Client:new( connection )
            local starting_state = Client.state:new( "login", "behaviours/login" )
            new_client:addState( starting_state )
            new_client:setState( starting_state )
            starting_state:init()
         else
            connection:close()
         end
      end
      coroutine.yield( EventQueue.default_tick * 8 ) -- every two second should be fine
   end
end

local function readFromClients( server )
   while true do
      for index, client in ipairs( server.connections ) do
         local input, err, partial = client.connection:receive( "*l" )
         if( not err ) then
            print( input )
         else
            if( err == 'closed' ) then
               table.remove( server.connections, index )
               client:close()
            end
         end
      end
      coroutine.yield( EventQueue.default_tick ) -- every quarter of a second to read from clients should be fine, can be adjusted if it feels sluggish
   end
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
   server.athread = coroutine.create( acceptNewConnection )

   return server;
end

function S:start()
   self.accepting = true
   return self.athread
end

function S:stop()
   self.accepting = false
end

return S

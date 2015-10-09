local C = {}

---------------------------------------------
-- Client Constants and Globals            --
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------


---------------------------------------------
-- Client Coroutines                       --
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------

local function getClientIP( client )
   while client.addr == nil do
      client.addr, client.port, client.net = client.connection:getsockname()
      if( client.addr == nil ) then
         coroutine.yield()
      end
   end
end

----------------------------------------------
-- Client methods                           --
-- Written by Daniel R. Koris(aka Davenge)  --
----------------------------------------------

function C:new( connect )
   local client = {}

   setmetatable( client, self )
   self.__index = self

   -- setup basic client info
   client.connection = connect
   client.connection:settimeout(0) -- don't block, you either have something or you don't!
   client.inbuf = {}
   client.outbuf = {}
   func = coroutine.wrap( getClientIP )
   func( client ) -- init the wrapped coroutine by passing it self

   return func, client;
end

function C:receive()
   local pattern, err = self.connection:receive('*l')

   if( not err ) then
      self.inbuf[#self.inbuf+1] = pattern
   elseif( err == "closed" ) then
      self.connection:close()
      return false
   end

   return true
end

function C:send()
   local output = table.concat( self.outbuf )

   if( #output > 0 ) then
      self.connection:send( output )
      self.outbuf = {}
   end
end

function C:close()
   self.connection:send( "You connection is being shut down..." )
   self.connection:close()
end

return C

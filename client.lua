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
      coroutine.yield()
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

   -- get the client info in a non-blocking way using an event

   return client;
end

function C:receive()
   self.inbuf[#self.inbuf + 1] =    
end

function C:send()

return C

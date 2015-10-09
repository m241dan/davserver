local C = {}

---------------------------------------------
-- Client Constants and Globals            --
-- Written by Daniel R. Koris(aka Davenge) --
---------------------------------------------


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

   return client;
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
   self.connection:send( "You connection is being shut down...\n" )
   self.connection:close()
end

return C

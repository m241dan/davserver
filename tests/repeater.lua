Server = require( "server" )

local server


function process()
   for i, c in ipairs( server.connections ) do
      for x, input in ipairs( c.inbuf ) do
         if( input == "shutdown" ) then
            run = false
         else
            c.outbuf[#c.outbuf+1] = c.addr .. ": " .. input .. "\n"
            table.remove( c.inbuf, x )
         end
      end
   end   
end

function main()
   local new_connects = {}

   server = assert( Server:new( 6500 ) )
   server:start()

   run = true
   while( run ) do
      -- accept new connections
      server:accept()
      -- poll the connections
      if( #server.connections > 0 ) then
         server:poll()
         process()
         server:push()
      end
   end
   server:stop()
   server:close()
end

main()


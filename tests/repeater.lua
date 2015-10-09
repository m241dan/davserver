Server = require( "server" )

local server


function process()
   for i, c in ipairs( server.connections ) do
      for x, input in ipairs( c.inbuf ) do
         if( input == "shutdown" ) then
            run = false
         else
            c.outbuf[#c.outbuf+1] = input
         end
      end
   end   
end

function main()
   local ipthreads = {}

   server = assert( Server:new( 6500 ) )
   server:start()

   run = true
   while( run ) do
      -- accept new connections
      local ipthread, client = server:accept()
      if( ipthread ~= nil ) then
         if( coroutine.status( ipthread ) ~= "dead" ) then
            ipthreads[#ipthreads+1] = ipthread
         end
      end

      -- run any ipthreads
      for i, thread in pairs( ipthreads ) do
         if( thread() == "dead" ) then
            table.remove( iptheads, i )
         end
      end

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


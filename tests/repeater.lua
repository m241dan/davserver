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

   server = Server:new( 6500 )

   run = true
   while( run ) do
      -- accept new connections
      local ipthread, client = server:accept()
      if( ipthread ~= nil ) then
         ipthreads[#ipthreads+1] = ipthread
      end

      -- run any ipthreads
      for i, thread in pairs( iptheads ) do
         if( thread() == "dead" ) then
            table.remove( iptheads, i )
         end
      end

      -- poll the connections
      if( #self.connections > 0 then
         server:poll()
         process()
         server:push()
      end
   end

   server:close()
end

main()


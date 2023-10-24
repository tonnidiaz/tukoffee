// Import the framework and instantiate it
import Fastify from 'fastify'
const fastify = Fastify({
  logger: true
})

// Declare a route
fastify.get('/', async function handler (request, reply) {
  return { hello: 'world' }
})

// Run the server!
 fastify.listen({ port: 8000 }).then(r=>{
    console.log("LISTENING ON:", r)
 }).catch(err=>{
    fastify.log.error(err)
    process.exit(1)
 })
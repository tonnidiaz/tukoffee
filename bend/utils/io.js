const io = require("socket.io")(); // yes, no server arg here; it's not required
// attach stuff to io
io.on("connection", (client) => {
    console.log("IO CONNECTED");
    
    io.emit("event", "This is event");
    client.on('event', (d)=>{
        console.log(d)
    })
});



module.exports = io;

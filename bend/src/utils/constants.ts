import multer from "multer"

enum OrderStatus {
    Pending = 'pending',
    Completed = 'completed',
    Cancelled = 'cancelled',
    AwaitingPickup = 'awaitingPickup'
}

enum OrderMode   {
    delivery = 'delivery',
    collect = 'collect'
}
enum UserPermissions  {
    read = 'read',
    write = 'write',
    delete = 'delete'
}



const parser = multer().none()

const DEV = process.env.NODE_ENV != 'production'
export { OrderStatus, UserPermissions, DEV, parser, OrderMode }

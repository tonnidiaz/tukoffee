export enum OrderStatus  {
    pending = 'pending',
    awaitingPickup = 'awaitingPickup',
    completed = 'completed',
    cancelled = 'cancelled',
}
export enum OrderMode   {
    delivery,
    collect
}
export enum UserPermissions  {
    read,
    write,
    delete
}


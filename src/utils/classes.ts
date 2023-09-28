export enum OrderMode { deliver, collect }
export enum SortOrder {
    ascending,
    descending,
}


export interface Obj {[key: string]: any}
export enum OrderStatus { all, pending, completed, cancelled}
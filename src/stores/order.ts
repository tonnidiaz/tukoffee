import { OrderStatus, SortOrder } from "@/utils/classes";
import { strToDate } from "@/utils/funcs";
import { defineStore } from "pinia";
export enum OrderSortBy {
    created,
    modified,
}


export const useOrderStore = defineStore("order", {
    state: () => ({
        orders: null as any[] | null,
        sortedOrders: null as any[] | null,
        sortBy: OrderSortBy.created,
        sortOrder: SortOrder.descending,
        status: OrderStatus.all
    }),

    actions: {
        setOrders(val: typeof this.orders) {
            this.orders = val;
            this.sort()
        },
        setSortedOrders(val: typeof this.sortedOrders) {
            this.sortedOrders = val;
            this.sort()
        },
        setStatus(val: typeof this.status) {
            this.status = val;
            let orders : any = []
            switch (val){
                case OrderStatus.pending:
                    orders = this.orders?.filter(el=> el.status == 'pending')
                    break;
                case OrderStatus.cancelled:
                    orders = this.orders?.filter(el=> el.status == 'cancelled')
                    break;
                case OrderStatus.completed:
                    orders = this.orders?.filter(el=> el.status == 'delivered')
                    break;
                default:
                    orders = this.orders;
                    break;
                
            }
            this.sort(orders)
        },
        setSortBy(val: OrderSortBy) {
            this.sortBy = val;
            this.sort()
        },
        setSortOrder(val: SortOrder) {
            this.sortOrder = val;
            this.sort()
        },
        toggleOrder(){
            console.log('TOGGLE')
            this.sortOrder = this.sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending
            this.sort()
        },
         sorter(a: any, b: any) {
            let s;
            const _sortOrder = this.sortOrder;
            switch (this.sortBy) {
                case OrderSortBy.created:
                    if (_sortOrder == SortOrder.ascending) {
                        s =  strToDate(a.date_created) > strToDate(b.date_created)  ? 1  : -1;
                    } else {
                        s =  strToDate(b.date_created) >  strToDate(a.date_created) ? 1  : -1;
                    }
                    break;
                case OrderSortBy.modified:
                    if (_sortOrder == SortOrder.ascending) {
                        s =  strToDate(a.last_modified) > strToDate(b.last_modified)  ? 1  : -1;
                    } else {
                        s =  strToDate(b.last_modified) >  strToDate(a.last_modified) ? 1  : -1;
                    }
                    break;
                default:
                    s = 0;
                    break;
            }
            return s;
        },
        sort(orders?: typeof this.orders) {
            this.sortedOrders = orders ?? this.orders
            this.sortedOrders?.sort(this.sorter)
        },
    },
});

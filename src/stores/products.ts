import { SortOrder, OrderStatus } from "@/utils/classes";
import { strToDate } from "@/utils/funcs";
import { defineStore } from "pinia";

export enum SortBy {
    created,
    modified,
    name,
}
export enum Status {
    in,
    out,
    all,
}


export const useProductsStore = defineStore('products', {
    state: ()=>({
        items: null as any[] | null,
        sortedItems: null as any[] | null,
        sortBy: SortBy.created,
        sortOrder: SortOrder.descending,
        status: Status.all
    }),
    actions: {
        setItems(val: typeof this.items) {
            this.items = val;
            this.sort()
        },
        setSortedItems(val: typeof this.sortedItems) {
            this.sortedItems = val;
            this.sort()
        },
        setStatus(val: typeof this.status) {
            this.status = val;
            let items : any = []
            switch (val){
                 case Status.in:
                    items = this.items?.filter(el=> el.quantity > 0)
                    break;
                case Status.out:
                    items = this.items?.filter(el=> el.quantity == 0)
                    break;
                default:
                    items = this.items;
                    break; 
                
            }
            this.sort(items)
        },
        setSortBy(val: SortBy) {
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
                case SortBy.name:
                    if (_sortOrder == SortOrder.ascending) {
                        s =  a.name > b.name  ? 1  : -1;
                    } else {
                        s =  b.name >  a.name ? 1  : -1;
                    }
                    break;
                case SortBy.created:
                    if (_sortOrder == SortOrder.ascending) {
                        s =  strToDate(a.date_created) > strToDate(b.date_created)  ? 1  : -1;
                    } else {
                        s =  strToDate(b.date_created) >  strToDate(a.date_created) ? 1  : -1;
                    }
                    break;
                case SortBy.modified:
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
        sort(items?: typeof this.items) {
            this.sortedItems = items ?? this.items
            this.sortedItems?.sort(this.sorter)
        },
    }
})
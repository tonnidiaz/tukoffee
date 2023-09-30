import { SortOrder } from "@/utils/classes";
import { strToDate } from "@/utils/funcs";
import { defineStore } from "pinia";

export enum SortBy {
    created,
    modified,
    price,
}
export enum Status {
    in,
    out,
    all,
    topSelling,
    onSpecial,
    onSale,
}

export const useShopStore = defineStore("shop", {
    state: () => ({
        items: null as any[] | null,
        sortedItems: null as any[] | null,
        sortBy: SortBy.created,
        sortOrder: SortOrder.descending,
        status: Status.all,
    }),
    actions: {
        setItems(val: typeof this.items) {
            this.items = val;
            this.sort(val);
        },
        setSortedItems(val: typeof this.sortedItems) {
            this.sortedItems = val;
            this.sort(val);
        },
        setStatus(val: typeof this.status) {
            this.status = val;
            let items: any = [];
            switch (val) {
                case Status.in:
                    items = this.items?.filter((el) => el.quantity > 0);
                    break;
                case Status.out:
                    items = this.items?.filter((el) => el.quantity == 0);
                    break;
                case Status.topSelling:
                    items = this.items?.filter((el) => el.top_selling);
                    break;
                case Status.onSpecial:
                    items = this.items?.filter((el) => el.on_special);
                    break;
                case Status.onSale:
                    items = this.items?.filter((el) => el.on_sale);
                    break;
                default:
                    items = this.items;
                    break;
            }
            this.sort(items);
        },
        setSortBy(val: SortBy) {
            this.sortBy = val;
            this.sort();
        },
        setSortOrder(val: SortOrder) {
            this.sortOrder = val;
            this.sort();
        },
        toggleOrder() {
            console.log("TOGGLE");
            this.sortOrder =
                this.sortOrder == SortOrder.ascending
                    ? SortOrder.descending
                    : SortOrder.ascending;
            this.sort();
        },
        sorter(a: any, b: any) {
            let s;
            const _sortOrder = this.sortOrder;
            console.log(this.status)
            switch (this.sortBy) {
                case SortBy.price:
                    if (_sortOrder == SortOrder.ascending) {
                        s = a.price > b.price ? 1 : -1;
                    } else {
                        s = b.price > a.price ? 1 : -1;
                    }
                    break;
                case SortBy.created:
                    if (_sortOrder == SortOrder.ascending) {
                        s =
                            strToDate(a.date_created) >
                            strToDate(b.date_created)
                                ? 1
                                : -1;
                    } else {
                        s =
                            strToDate(b.date_created) >
                            strToDate(a.date_created)
                                ? 1
                                : -1;
                    }
                    break;
                case SortBy.modified:
                    if (_sortOrder == SortOrder.ascending) {
                        s =
                            strToDate(a.last_modified) >
                            strToDate(b.last_modified)
                                ? 1
                                : -1;
                    } else {
                        s =
                            strToDate(b.last_modified) >
                            strToDate(a.last_modified)
                                ? 1
                                : -1;
                    }
                    break;
                default:
                    s = 0;
                    break;
            }
            return s;
        },
        sort(items?: typeof this.items) {
            this.sortedItems = items ?? this.items;
            this.sortedItems?.sort(this.sorter);
        },
    },
});

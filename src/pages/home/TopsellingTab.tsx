

import { IonCol, IonContent, IonItem, IonPage, IonRow, IonSelect, IonSelectOption, IonTitle } from "@ionic/react";
import { useState } from "react";
import ProductCard from "../../components/ProductCard";

enum SortBy{ name, price, date}
const testProducts =    [
    {
        name: "Apple",
        price: 4.5,
        quantity: 3,
        rating: 2,
    },
    {
        name: "Orange",
        price: 2,
        quantity: 1,
        rating: 3,
    },
    {
        name: "Banana",
        price: 7.8,
        quantity: 5,
        rating: 4.5,
    },
    {
        name: "Mango",
        price: 4.5,
        quantity: 3,
        rating: 2,
    },
];
const TopsellingTab = () => {

    const [products, setProducts] = useState(testProducts)
    return ( <IonPage>
          <IonContent>
            <div className="column">
                <IonRow>
                    <IonCol>
                        <IonItem>
                            <IonSelect label="Sort by" labelPlacement="floating">
                                <IonSelectOption value={SortBy.name}>Name</IonSelectOption>
                                <IonSelectOption value={SortBy.price}>Price</IonSelectOption>
                                <IonSelectOption value={SortBy.date}>Date</IonSelectOption>
                            </IonSelect>
                        </IonItem>
                       
                    </IonCol>
                    <IonCol>
                    <IonItem>
                            <IonSelect label="Status" labelPlacement="floating">
                                <IonSelectOption value={"in"}>In stock</IonSelectOption>
                                <IonSelectOption value={"out"}>Out of stock</IonSelectOption>
                            </IonSelect>
                        </IonItem>
                        </IonCol>
                </IonRow>
                <div className="row wrap products-cont scroll-v">
                        { products.map((it, i)=>{
                            return <ProductCard key={`prod-${i * Date.now()}`}/>
                        })}
                </div>
            </div>
        </IonContent>
    </IonPage> );
}
 
export default TopsellingTab;
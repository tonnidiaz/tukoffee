import { IonButton, IonCard, IonCardContent, IonCardHeader, IonCardSubtitle, IonCardTitle, IonCol, IonHeader, IonIcon, IonItem, IonList, IonRippleEffect, IonRow, IonTitle } from "@ionic/react";
import { bagAdd, star } from "ionicons/icons";
import "./ProductItem.scss"
const ProductItem = () => {
    return ( 
    
    <IonCard routerLink={`/product/${4587}`} className="product-item" >
    <IonRow  >
        <div className="img-area">
        <img alt="Product image" src="/images/coffee2.jpg" />
        <IonButton className="cart-btn">
            <IonIcon slot="icon-only" ios={bagAdd}/>
        </IonButton>
        </div>
        <div className="content">
          
            <h5 className="item-title">Product title Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit laborum est natus, recusandae iusto excepturi reprehenderit fugiat voluptate quisquam ut, ad accusantium aliquam tenetur, labore nisi! Aliquid, exercitationem! Veniam, magnam?</h5>
            <span>$5.99</span>
            <IonRow><IonCol><span>In stock</span></IonCol>
                <IonCol >
                    <IonIcon ios={star}/>
                    <code>5</code>
                </IonCol>  
            </IonRow>
            
        </div>
        
     <IonButton color={"dark"} fill="clear" style={{padding: 0}}>
        <IonIcon slot="icon-only" ios={bagAdd}/>
     </IonButton>
    </IonRow>
    </IonCard>
     );
}
 
export default ProductItem;
import { IonButton, IonCard, IonCardContent, IonCardHeader, IonCardSubtitle, IonCardTitle, IonCol, IonHeader, IonIcon, IonRow } from "@ionic/react";
import { bagAdd, star } from "ionicons/icons";
import "./ProductCard.scss"
const ProductCard = () => {
    return ( <IonCard>
        <div className="img-area">
        <img alt="Product image" src="/images/coffee2.jpg" />
        <IonButton className="cart-btn">
            <IonIcon slot="icon-only" ios={bagAdd}/>
        </IonButton>
        </div>

        <IonCardHeader>
            <IonCardTitle>Name</IonCardTitle>
            <IonCardSubtitle>In stock</IonCardSubtitle>
        </IonCardHeader>
        <IonCardContent>
            <IonRow>
                <IonCol><span>$5.77</span></IonCol>
                <IonCol style={{ textAlign: "end"}}>
                    <IonIcon ios={star}/>
                    <code>5</code>
                </IonCol>
            </IonRow>
        </IonCardContent>
    </IonCard> );
}
 
export default ProductCard;
import { IonButton, IonButtons, IonCard, IonCardContent, IonCardHeader, IonCardSubtitle, IonCardTitle, IonCol, IonContent, IonGrid, IonHeader, IonIcon, IonImg, IonLabel, IonModal, IonPage, IonRow, IonText, IonTitle, IonToolbar } from "@ionic/react";
import { arrowBack, bagAddOutline, cart, star } from "ionicons/icons";
import React, { useEffect, useState } from "react";
import { RouteComponentProps, useHistory, useRouteMatch } from "react-router";
import Titlebar from "../components/Titlebar";

interface ProductPageProps extends RouteComponentProps<{
    id: string
}>{}
const ProductPage : React.FC<ProductPageProps> = ({match}) => {
const [cnt,setcnt] = useState(0)
   // const match = useRouteMatch();
useEffect(()=>{
}, [])
  return ( 
        <IonPage>
            <Titlebar>
                    <IonButtons slot="start">
                        <IonButton color={"dark"}>
                                <IonIcon slot="icon-only" ios={arrowBack}/>
                        </IonButton>
                    </IonButtons>
                    <IonTitle>Tukoffee</IonTitle>
            </Titlebar>
            <IonContent>
                <IonTitle >Product#{`${match.params.id}`}</IonTitle>
                <IonCard>  <IonImg src="/images/coffee2.jpg"/>
                    <IonCardHeader>
                            <IonCardTitle>Product name</IonCardTitle>
                            <IonCardSubtitle>In stock</IonCardSubtitle>
                    </IonCardHeader>
                    <IonCardContent>
                    <IonButton onClick={()=> setcnt(cnt+ 1)}><IonLabel>Counter: {cnt}</IonLabel></IonButton>

                        <IonText>
                            Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptate dignissimos est, error laboriosam necessitatibus repellat asperiores optio culpa impedit sint, provident quaerat? Voluptatibus explicabo totam tempore vel unde sequi numquam?
                        </IonText>
                    </IonCardContent>
                </IonCard>
            </IonContent>   

            <IonModal isOpen={true} initialBreakpoint={0.2} breakpoints={[0, 0.2]}  backdropDismiss={false} canDismiss={false}>
                <IonContent style={{height: 300}} className="scroll-v">
                    <IonGrid>
                        <IonRow className="ai-center">
                            <IonCol>
                                <h5>Rate product:</h5>
                            </IonCol>
                                <IonIcon ios={star}/>
                        </IonRow>
                    <IonRow className="ai-center">
                        <IonCol>
                            <span>$5.99</span>
                        </IonCol>
                    <IonButton>
                        <IonIcon slot="start" ios={cart}/>
                        <IonLabel>Add to cart</IonLabel>
                    </IonButton>
                    </IonRow>
                    </IonGrid>
                </IonContent>
            </IonModal>
        </IonPage>
     );
}
 
export default ProductPage;
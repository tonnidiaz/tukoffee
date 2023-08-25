import { IonContent, IonHeader, IonMenu, IonText, IonTitle, IonToolbar } from "@ionic/react";

const Drawer = () => {
    return ( 
        <IonMenu contentId="main-content" type="push">
            <IonHeader class="ion-no-border">
                <IonToolbar>
                    <IonTitle>Tukoffee</IonTitle>
                </IonToolbar>
            </IonHeader>
            <IonContent>
                <IonText>The content</IonText>
            </IonContent>
        </IonMenu>
     );
}
 
export default Drawer;
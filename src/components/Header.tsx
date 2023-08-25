import { IonButton, IonButtons, IonHeader, IonIcon, IonMenuButton, IonTitle, IonToolbar } from "@ionic/react"
import {bag, ellipsisVertical} from 'ionicons/icons'
const Header : React.FC = ()=>{
    return <IonHeader class="ion-no-border">
        <IonToolbar>
            <IonButtons slot="start">
                <IonMenuButton color={"dark"} ></IonMenuButton>
            </IonButtons>
            <IonTitle>Tunedbass</IonTitle>
            <IonButtons slot="end">
                <IonButton color={"dark"}>
                    <IonIcon slot="icon-only" ios={bag}></IonIcon>
                </IonButton>
                <IonButton color={"dark"}>
                    <IonIcon slot="icon-only" ios={ellipsisVertical}></IonIcon>
                </IonButton>
            </IonButtons>
        </IonToolbar>
    </IonHeader>
}

export default Header

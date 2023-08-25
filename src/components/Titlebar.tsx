import { IonHeader, IonToolbar } from "@ionic/react";
import React from "react";

const Titlebar = ({children} : { children: React.ReactNode}) => {
    return ( <IonHeader class="ion-no-border">
        <IonToolbar>
            { children }
        </IonToolbar>
    </IonHeader> );
}
 
export default Titlebar;
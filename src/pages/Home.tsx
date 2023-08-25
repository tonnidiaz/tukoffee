import {
    IonContent,
    IonHeader,
    IonLabel,
    IonPage,
    IonRouterOutlet,
    IonTabBar,
    IonTabButton,
    IonTabs,
    IonTitle,
    IonToolbar,
} from "@ionic/react";
import Header from "../components/Header";
import "./Home.css";
import Drawer from "../components/Drawer";
import { Route, useHistory } from "react-router";
import TrendingTab from "./home/TrendingTab";
import { IonReactRouter } from "@ionic/react-router";
import TopsellingTab from "./home/TopsellingTab";
import { useEffect } from "react";

const Home: React.FC = () => {
    const history = useHistory()
    useEffect(()=>{
        history.push("/trending")
    },[])
    return (
        <><Drawer />
         <Header/>
            <IonContent>
            <IonTabs>
                <IonRouterOutlet>
                    <Route
                        path="/trending"
                        exact
                        render={() => <TrendingTab />}
                    />
                    <Route
                        path="/top-selling"
                        exact
                        render={() => <TopsellingTab />}
                    />
                </IonRouterOutlet>

                <IonTabBar slot="top">
                    <IonTabButton tab="trending" href="/trending">
                        <IonLabel>Trending</IonLabel>
                    </IonTabButton>
                    <IonTabButton tab="top-selling" href="/top-selling">
                        <IonLabel>Top selling</IonLabel>
                    </IonTabButton>
                </IonTabBar>
            </IonTabs>
            </IonContent>
        </>
    );
};

export default Home;

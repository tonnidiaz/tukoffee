<template>
    <ion-page>
        <Appbar title="Settings" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="p-1">
                <IonItemGroup class="mb-1 bg-base-100">
                    <ion-item color="clear">
                        <ion-toggle color="secondary" 
                        @ion-change="setAutoCheckUpdates($event.target.checked);"
                        :checked="autoCheckUpdates" class="p- m-0">Auto check updates</ion-toggle>
                    </ion-item>
                    <ion-item color="clear">
                        <ion-label>
                            <h3 class="fs-15">App version</h3>
                        </ion-label>
                        <ion-note slot="end" class="fs-15 fw-6">{{
                            appVersion
                        }}</ion-note>
                    </ion-item>
                    <ion-item
                        lines="none"
                        color="clear"
                        @click="updatesLoadingOpen = true"
                    >
                        <ion-label>
                            <h3 class="fs-15">Check updates</h3>
                        </ion-label>
                        <ion-loading
                            @did-present="checkUpdates"
                            @did-dismiss="updatesLoadingOpen = false"
                            color="dark"
                            class="tu"
                            message="Checking updates"
                            :is-open="updatesLoadingOpen"
                        />
                    </ion-item>
                </IonItemGroup>
            </div>

            <!-- Updates sheet -->
            <bottom-sheet
                :can-dismiss="() => !installingUpdates"
                no-swipe-dismiss
                :is-open="updatesSheetOpen"
                @did-dismiss="updatesSheetOpen = false"
            >
                <div v-if="!installingUpdates" class="p-3 bg-base-100">
                    <div v-if="update?.version">
                        <h3 class="mt-5 fs-20">Updates available</h3>
                        <div class="my-4">
                            <div class="flex items-center justify-between">
                                <h4 class="fs-16 fw-5">Version:</h4>
                                <h4 class="fs-16 fw-5">{{ update.version }}</h4>
                            </div>
                        </div>
                        <section>
                            <h3 class="fw-5 fs-17 my-4">Release notes</h3>
                        </section>
                        <ul
                            class="default"
                            style="max-height: 150px; overflow-y: scroll"
                        >
                            <li v-for="(note, i) in update.notes">
                                {{ note }}
                            </li>
                        </ul>
                        <div class="my-2">
                            <tu-btn
                                @click="installUpdate"
                                ionic
                                color="success"
                                class="w-full tu"
                                >Update now</tu-btn
                            >
                        </div>
                    </div>
                    <div v-else>
                        <h3 class="fw-5 text-center">{{ update }}</h3>
                    </div>
                </div>
                <div v-else class="p-3 bg-base-100">
                    <div class="my-4">
                        <ion-progress-bar
                            color="success"
                            :value="progress / 100"
                        />
                        <h3 class="fw-5 text-center mt-3">
                            Downloading update...
                        </h3>
                    </div>
                </div>
            </bottom-sheet>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonItem,
    IonItemGroup,
    IonLabel,
    IonNote,
    IonLoading,
    IonProgressBar,
    IonToggle,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Filesystem, Directory, ProgressStatus } from "@capacitor/filesystem";
import { onMounted, ref } from "vue";
import { showToast, sleep } from "@/utils/funcs";
import { FileOpener } from "@capawesome-team/capacitor-file-opener";
import axios from "axios";
import { tbURL } from "@/utils/constants";
import { AppVersion } from "@ionic-native/app-version";

const autoCheckUpdates = ref(true)

const appVersion = ref<string | null>();
const update = ref<any>("Version up-to-date");

const updatesLoadingOpen = ref(false);
const updatesSheetOpen = ref(false),
    installingUpdates = ref(false);
const progress = ref(0);


const setAutoCheckUpdates = (val: boolean)=>{
    localStorage.setItem('auto_check_updates', `${val}`)
    
}
const installUpdate = async () => {
    const dir = Directory.Data,
        pth = "/files/downloads/";

    /* Show installing dialog */
    installingUpdates.value = true;
    try {
        const rr = await Filesystem.readdir({ directory: dir, path: pth });
        console.log(rr);
    } catch (err: any) {
        console.log(err);
        await Filesystem.mkdir({
            directory: dir,
            recursive: true,
            path: pth,
        });
        console.log("Directory created");
    }
    progress.value = 0;
    try {
        console.log(update.value.file);
        const res = await Filesystem.downloadFile({
            directory: dir,
            path: pth + "/app.apk",
            progress: true,
            url: update.value.file,
            recursive: true,
        });
        console.log(res);
        installingUpdates.value = false;
        /* Close sheets and dialogs */
        updatesSheetOpen.value = false;

        await sleep(500);
        await FileOpener.openFile({
            path: res.path!,
        });
    } catch (e) {
        console.log(e);
        updatesSheetOpen.value = false;
        installingUpdates.value = false;
        showToast({ msg: "Failed to download update", cssClass: "ion-danger" });
    }
};
const checkUpdates = async () => {
    try {
        const res = await axios.get(`${await tbURL()}/api/app/updates/check`, {
            params: {
                uid: "com.tb.tukoffee",
                v: appVersion.value,
            },
        });  

        update.value = res.data;
        updatesLoadingOpen.value = false;
        updatesSheetOpen.value = true;
    } catch (e) {
        console.log(e);
        updatesLoadingOpen.value = false;
        showToast({ msg: "Failed to check update", cssClass: "ion-danger" });
    }
};
const onProgress = (e: ProgressStatus) => {
    const prog = (e.bytes * 100) / e.contentLength;
    progress.value = prog;
};
onMounted(() => {
    (async function () {
        const acu = localStorage.getItem('auto_check_updates')
        autoCheckUpdates.value =  acu ? acu == 'true' : true
        const v = await AppVersion.getVersionNumber();
        appVersion.value = v;
    })();

    Filesystem.addListener("progress", onProgress);
});
</script>

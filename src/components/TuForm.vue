<template>
    <form @submit="_onSubmit" ref='formRef' action="">
        <slot/>
    </form>
</template>
<script setup lang="ts">
const props = defineProps({
    onSubmit: Function
})

const _onSubmit = async (e: any)=>{
    e.preventDefault()
    const btns = [...e.target.querySelectorAll('button[type=submit]')].concat([...e.target.querySelectorAll('ion-button')]).filter(it=> it.type == 'submit')
    btns.forEach((btn: any)=>{
        btn.disabled = true})
    if (props.onSubmit){await props.onSubmit(e)}
    btns.forEach((btn: any)=>btn.disabled = false)
}
</script>
import Vue   from 'vue';
import local from '../services/local.api';

export default {
    namespaced: true,
    state:      {
        instrList: []
    },
    mutations:  {
        instrList: []
    },
    actions:    {
        getInstrList(ctx, payload) {
            return local.get('/instr/list', {params: payload})
                .then(({data}) => {
                    if (data.result) {
                        return data.data
                    } else {
                        console.log(data);
                        ctx.dispatch('showError', data, {root:true});
                    }
                })
                .catch(e => ctx.dispatch('showError', e, {root:true}))
        },
        addInstr(ctx, payload) {
            return local.post('/instr/add', payload)
            .then(({data}) => {
                if (data.result) {
                    return data.data
                } else {
                    console.log(data);
                    ctx.dispatch('showError', data, {root:true});
                }
            })
            .catch(e => ctx.dispatch('showError', e, {root:true}))
        },
        updatInstr(ctx, payload) {
            return local.post('/instr/update', payload)
            .then(({data}) => {
                if (data.result) {
                    return data.data
                } else {
                    console.log(data);
                    ctx.dispatch('showError', data, {root:true});
                }
            })
            .catch(e => ctx.dispatch('showError', e, {root:true}))
        },
        enableInstr(ctx, payload) {
            return local.post('/instr/enable', payload)
            .then(({data}) => {
                if (data.result) {
                    return data.data
                } else {
                    console.log(data);
                    ctx.dispatch('showError', data, {root:true});
                }
            })
            .catch(e => ctx.dispatch('showError', e, {root:true}))
        },
        disableInstr(ctx, payload) {
            return local.post('/instr/disable', payload)
            .then(({data}) => {
                if (data.result) {
                    return data.data
                } else {
                    console.log(data);
                    ctx.dispatch('showError', data, {root:true});
                }
            })
            .catch(e => ctx.dispatch('showError', e, {root:true}))
        },
        statInstr(ctx, payload) {
            return local.post('/instr/stat', payload)
            .then(({data}) => {
                if (data.result) {
                    return data.data
                } else {
                    console.log(data);
                    ctx.dispatch('showError', data, {root:true});
                }
            })
            .catch(e => ctx.dispatch('showError', e, {root:true}))
        }
    }
}

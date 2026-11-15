RegisterNetEvent('qbx_editor:client:openMenu', function()
    lib.registerContext({
        id = 'qbx_editor_menu',
        title = 'Kayıt ve Editör',
        options = {
            {
                title = 'Kayda Başla',
                description = 'Oyun içi kaydı başlatır',
                icon = 'video',
                onSelect = function()
                    StartRecording(1)
                    exports.qbx_core:Notify(locale('success.started_recording'), 'success')
                end
            },
            {
                title = 'Kaydı Durdur',
                description = 'Devam eden kaydı durdurur',
                icon = 'stop',
                onSelect = function()
                    StartRecording(0)
                    exports.qbx_core:Notify(locale('success.stopped_recording'), 'success')
                end
            },
            {
                title = 'Klibi Kaydet',
                description = 'Kaydı durdurur ve klibi kaydeder',
                icon = 'floppy-disk',
                onSelect = function()
                    StopRecordingAndSaveClip()
                    exports.qbx_core:Notify(locale('success.saved_recording'), 'success')
                end
            },
            {
                title = 'Klibi Sil',
                description = 'Kaydı durdurur ve klibi siler',
                icon = 'trash',
                onSelect = function()
                    StopRecordingAndDiscardClip()
                    exports.qbx_core:Notify(locale('error.deleted_recording'), 'error')
                end
            },
            {
                title = 'Editörü Aç',
                description = 'Rockstar Editörü başlatır',
                icon = 'film',
                onSelect = function()
                    NetworkSessionLeaveSinglePlayer()
                    ActivateRockstarEditor()
                    exports.qbx_core:Notify(locale('error.later_aligator'), 'error')
                end
            }
        }
    })

    lib.showContext('qbx_editor_menu')
end)

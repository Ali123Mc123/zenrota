shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_studentphone'
author 'Daddy Studio'
description 'Student Phone: timetable, homework, focus, notes and school messages on a phone'
version '2.0.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

-- The phone in the hand, one prop per case colour (stream/daddy_phone_<colour>.ydr): the frame of Settings > Display.
data_file 'DLC_ITYP_REQUEST' 'stream/daddy_phone_silver.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/daddy_phone_orange.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/daddy_phone_blue.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/daddy_phone_black.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/daddy_phone_cherry.ytyp'

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
}

client_scripts {
    'client/pose.lua',
    'client/main.lua',
    'client/notify.lua',
    'client/focus.lua',
    'client/alarms.lua',
    'client/college.lua',
    'client/dorms.lua',
    'client/flashlight.lua',
    'client/orientation.lua',
    'client/call.lua',
    'client/camera.lua',
    'client/share.lua',
    'client/card.lua',
    'client/external.lua',
    'client/maps.lua',
    'client/apps.lua',
    'client/garage.lua',
    'client/payphone.lua',
    'client/charger.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/logs.lua',
    'server/notify.lua',
    'server/lockscreen.lua',
    'server/checks.lua',
    'server/school.lua',
    'server/live.lua',
    'server/classlock.lua',
    'server/exammode.lua',
    'server/schedule.lua',
    'server/homework.lua',
    'server/notes.lua',
    'server/exams.lua',
    'server/focus.lua',
    'server/inbox.lua',
    'server/chat.lua',
    'server/card.lua',
    'server/contacts.lua',
    'server/numbers.lua',
    'server/calls.lua',
    'server/media.lua',
    'server/mediastore.lua',
    'server/profiles.lua',
    'server/voice.lua',
    'server/video.lua',
    'server/airdrop.lua',
    'server/usage.lua',
    'server/passcode.lua',
    'server/battery.lua',
    'server/pay.lua',
    'server/mail.lua',
    'server/market.lua',
    'server/tunes.lua',
    'server/dating.lua',
    'server/services.lua',
    'server/albums.lua',
    'server/clips.lua',
    'server/crypto.lua',
    'server/browser.lua',
    'server/garage.lua',
    'server/ride.lua',
    'server/phoneadmin.lua',
    'server/dict.lua',
    'server/search.lua',
    'server/schoolapp.lua',
    'server/clubs.lua',
    'server/events.lua',
    'server/courses.lua',
    'server/alarms.lua',
    'server/timers.lua',
    'server/calendar.lua',
    'server/ranks.lua',
    'server/wifi.lua',
    'server/bell.lua',
    'server/maps.lua',
    'server/staff.lua',
    'server/academy.lua',
    'server/quiz.lua',
    'server/janitor.lua',
    'server/notices.lua',
    'server/social/guard.lua',
    'server/social/confess.lua',
    'server/social/councilbox.lua',
    'server/social/moderate.lua',
    'server/social/cm/core.lua',
    'server/social/cm/accounts.lua',
    'server/social/cm/posts.lua',
    'server/social/cm/people.lua',
    'server/social/cm/activity.lua',
    'server/social/cm/moments.lua',
    'server/social/cm/dm.lua',
    'server/social/cm/staff.lua',
    'server/social/whisper.lua',
    'server/press.lua',
    'server/wishes.lua',
    'server/dorms.lua',
    'server/apps.lua',
    'server/external.lua',
    'server/exports.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'install/**/*.lua',
}

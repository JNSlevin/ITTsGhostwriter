# ITT's Ghostwriter
## About
As a guildmaster of various trading guilds I have realized over the years that the membernotes are one of the most important features in leading a guild.
They are the only way to store additional information on guildmembers. 
As such in my guilds the notes are rather important and since members do not know whats important and whats not they will leave the guild for various reasons and will not tell us about it.
Resulting in that important information being lost.

So I sat down and started to write an addon which helps me recover that lost information by saving it locally.
Over the time i added various features which i did manually in my guilds, including setting the note for new members and sending a welcome mail explaning what the guild is about etc.
Additionally most addons we use for administrative work in our guilds are either ancient or lacking. 
We as ITT released another addon (done by the amazing @ghostbane) which helps us track donations relieably since the only other addon we were aware of that did this was broken since the history change on ZOS' side.
I thought since i recently learned more and more about programming i could give it a shot.
Therfore Ghostwriter was born.

### Setup
Ghostwriter is a permission based addon, as such if you first install it without setup it wont do anything. 
This was done to prevent accidental spamming of new members (if 27 people in a guild have this addon and have the welcome mail enabled the newcomer might get 27 mails). 
    
Ghostwriter will search the notes of guildmembers for its permission pattern. 
The notes being one of the only 3 ways to exchange information in real time with other members and their addons (the other 2 being the MotD and about-us). 
So theoretically people who can change their notes could change the permissions. 
If you do not want that, change the guildpermissions for editing notes!

First steps: Think about who of your staff should send a welcome mail, who should set the note for new members (the backup option is tethered to the addons noting permission to prevent people who shouldnt be able to to export your notes) and who should write a welcome message in the chat. 
After you decided who does what, edit their notes! The pattern is specifically made to be invisible when previewing notes! It will only be visible when editing the note!

#### List of patterns: 
*  NOTE PATTERN =          `|cGWnote|r`
*  MAIL PATTERN =          `|cGWmail|r`
*  CHAT PATTERN =          `|cCWchat|r`
*  NOTE + MAIL PATTERN =   `|cGWnoma|r`
*  NOTE + CHAT PATTERN =   `|cGWnoch|r`
*  MAIL + CHAT PATTERN =   `|cGWmach|r`
*  PATTERN FOR ALL =       `|cGWxxxx|r`
    

##### Once this pattern is in the note, the settings for each guild will be available where you do have the permission.

### Available Settings
Ghostwriter offers various settings to customize your use for it.
These settings include:
#### General
- Enabling to check for Onlinestatus before posting the welcome chat message 
  * I have learned that since the guildfinder was introduced, most of the time when people join the guild they arent online)
- Enabling to check for the time people are offline upon joining the guild 
  * The maximum amount of time an application is active is 15 days, so when people are offline for longer than 14 days it will include an offlinemode warning in the note
  * Enabling or disabling a button in the guildroster to backup notes in the selected guild!
- Enabling the backup button in the Guildroster!

#### Guildspecific
##### First choose the guild you would like to change the settings for!
- Choose the date format for the date replacement
- Set an application threshhold 
  *most guilds will get a ton of empty applications, so some of them have a threshold of champion points where they accept the applicant anyway
- Enable the chatmessage
  - Set the template
- Enable the note 
  - Set the template
- Enable the Mail
  - Set both templates
- Preview the Mail
##### Backup options
- Automatically backup notes upon 
  * Login
  * Reload UI
  * When the note gets changed
    * This will overwrite older notes rather fast, so retrieving specific notes will be harder.

### Miscellaneous features

Basically as i have written this addon i had a bunch of ideas which i thought would be helpful

#### Guildroster Column
Will indicate if a note is saved (green), if a note is not saved yet (grey), if a different note is saved by the addon (orange) and if a note is saved by the addon but not saved in the roster notes.


#### GuildLinks
Any of the system messages which include a specific guild will have a link for that guild in them, these links include:
* The name of the guild
* The color you chose in the vanilla settings for each guild
* clicking the link will result in:
   - Leftclick = opening the guild home
   - Rightlick = opening a context menu in which you can choose which part of the guildmenu you want to open!
   - Middleclick (the mousewheel) = opening the applications window (if you do not have the manage applications permission it will show the guildroster!
        
        
#### Alerts

Will post a message in your system chat when:
* A note is changed
* A new application arrives 
   - will include the number of applications + how many are empty + how many are above in the threshhold you set in the settings
    
    
#### Context Menus

Added context menus in:
   * The guildroster to:
        - Backup the note 
        - retrieve the note in storage
        - initiate welcome sequence (The steps you have set when a new member has joined)
   * The playerlink:
        - Invites to all the guilds you have permission to invite for
    

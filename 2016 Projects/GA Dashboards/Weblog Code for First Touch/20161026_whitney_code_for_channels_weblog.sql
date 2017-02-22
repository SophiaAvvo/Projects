
case when v3.partner_source is not null then 'Paid Call Channels'
when lpv_medium in ('utm_medium=affiliate', 'utm_medium=affiliates', 'utm_medium=affiliawww')
                    or lpv_source in ('utm_source=boomerater', 'utm_source=boomerater%20', 'utm_source=lifecare', 'utm_source=affiliates', 'utm_source=affiliate')
                    then 'Marketing - Affiliates'
when lpv_medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or lpv_source = 'utm_source=email'
                    then 'Marketing - Email'
when lpv_campaign like 'utm_campaign=FB_%' or lpv_source in ('utm_source=facebook', 'utm_source=twitter', 'utm_source=linkedin', 'utm_source=gplus', 'utm_source=plus',
                                                             'utm_source=googleplus', 'utm_source=youtube', 'utm_source=pinterest', 'utm_source=twitterfeed',
                                                             'utm_source=Facebook', 'utm_source=Twitter',
                                                             'utm_source=SocialProof', 'utm_source=thetwitter', 'utm_source=faceb', 'utm_source=social')
                                           or lpv_medium in ('utm_medium=facebook', 'utm_medium=twitter')
                    then 'Marketing - Social'
when lpv_content = 'utm_content=adblock' or (lpv_campaign = 'utm_campaign=adblock' and lpv_content != 'utm_content=brand')
                    then 'SEM - Adblock'
when lpv_content = 'utm_content=sgt' or lpv_medium = 'utm_medium=sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' or lpv_campaign = 'utm_campaign=sgt'
                    then 'SEM - Network'
when (lpv_medium in ('utm_medium=display','utm_medium=video','utm_medium=mobile_video', 'utm_medium=mobile', 'utm_medium=content', 'utm_medium=mobile_tablet')
                    and lpv_source != 'utm_source=google' and lpv_source != 'utm_source=gsp')
                    or lpv_source = 'utm_source=Outbrain'
                    then 'Marketing - Digital Brand and Engagement'
when lpv_campaign in ('utm_campaign=brand', 'utm_campaign=Branded_Terms', 'utm_campaign=legalbroad') or lpv_content = 'utm_content=brand'
                    then 'Marketing - SEM Brand'
when lpv_medium = 'utm_medium=sem' or lpv_medium = 'utm_medium=cpc' or lpv_medium = 'utm_medium=sem%3Fpromo_code%3DAVVO25'
                    then 'Marketing - SEM Nonbrand'
when lpv_campaign like 'utm_campaign=pls%' or lpv_campaign like 'utm_campaign=PLS%' 
                    then 'Marketing - Other Paid Marketing'
when lpv_medium in ('utm_medium=avvo_badge', 'utm_medium=avvo_badg', 'utm_medium=avvo_bad', 'utm_medium=avvo_ba', 'utm_medium=avvo_b')
                    then 'Other - Avvo Badge'
else 'Marketing - Other Paid Marketing' end channel

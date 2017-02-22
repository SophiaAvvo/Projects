tabcmd login -s https://tableau.prod.avvo.com -u srobinson --password-file pwd.txt

tabcmd get "/views/UserActivityMetrics/WeeklySessionMetrics.png" -f "C:\Users\srobinson\Documents\TabCMD\view1.png" --timeout 500

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/RUEngagementDetail.png" -f "C:\Users\srobinson\Documents\TabCMD\view2.png" --timeout 500

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/PathPA.png" -f "C:\Users\srobinson\Documents\TabCMD\view3.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view3.png" "C:\Users\srobinson\Documents\TabCMD\view4.png"

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/RUDemographics.png" -f "C:\Users\srobinson\Documents\TabCMD\view5.png" --timeout 500

tabcmd get "/views/FinanceDashboard/ClaimsAdv.png" -f "C:\Users\srobinson\Documents\TabCMD\view6.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view6.png" "C:\Users\srobinson\Documents\TabCMD\view7.png" --timeout 500

tabcmd get "/views/FinanceDashboard/Contacts.png" -f "C:\Users\srobinson\Documents\TabCMD\view8.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view8.png" "C:\Users\srobinson\Documents\TabCMD\view9.png" --timeout 500

tabcmd get "/views/FinanceDashboard/Contacts.png" -f "C:\Users\srobinson\Documents\TabCMD\view8.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view8.png" "C:\Users\srobinson\Documents\TabCMD\view10.png" --timeout 500

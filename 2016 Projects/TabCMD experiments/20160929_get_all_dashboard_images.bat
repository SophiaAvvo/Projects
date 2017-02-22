tabcmd login -s https://tableau.prod.avvo.com -u srobinson --password-file amiga.txt

tabcmd get "/views/UserActivityMetrics/WeeklySessionMetrics.png" -f "C:\Users\srobinson\Documents\TabCMD\view1.png" --timeout 500

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/RUEngagmentDetail.png" -f "C:\Users\srobinson\Documents\TabCMD\view2.png" --timeout 500

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/PathPA.png" -f "C:\Users\srobinson\Documents\TabCMD\view3.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view3.png" "C:\Users\srobinson\Documents\TabCMD\view4.png"

tabcmd get "/views/CombinedRegisteredUserDashboardCRUD/RUDemographics.png" -f "C:\Users\srobinson\Documents\TabCMD\view5.png" --timeout 500

tabcmd get "/views/FinanceDashboard/ClaimsAdv.png" -f "C:\Users\srobinson\Documents\TabCMD\view6.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view6.png" "C:\Users\srobinson\Documents\TabCMD\view7.png" 

tabcmd get "/views/FinanceDashboard/Contacts.png" -f "C:\Users\srobinson\Documents\TabCMD\view8.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view8.png" "C:\Users\srobinson\Documents\TabCMD\view9.png" 

tabcmd get "/views/FinanceDashboard/QA.png" -f "C:\Users\srobinson\Documents\TabCMD\view10.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view10.png" "C:\Users\srobinson\Documents\TabCMD\view11.png" 

copy "C:\Users\srobinson\Documents\TabCMD\view10.png" "C:\Users\srobinson\Documents\TabCMD\view12.png" 

tabcmd get "/views/FinanceDashboard/ReviewEndorse.png" -f "C:\Users\srobinson\Documents\TabCMD\view13.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view13.png" "C:\Users\srobinson\Documents\TabCMD\view14.png" 

tabcmd get "/views/MRRAllProducts/Summary.png" -f "C:\Users\srobinson\Documents\TabCMD\view15.png" --timeout 500

tabcmd get "/views/DigitalMarketingChannelReportGA/KPIOverview.png" -f "C:\Users\srobinson\Documents\TabCMD\view16.png" --timeout 500

tabcmd get "/views/DigitalMarketingChannelReportGA/ConsumerKPIs.png" -f "C:\Users\srobinson\Documents\TabCMD\view17.png" --timeout 500

tabcmd get "/views/DigitalMarketingChannelReportGA/LawyerKPIs.png" -f "C:\Users\srobinson\Documents\TabCMD\view18.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view17.png" "C:\Users\srobinson\Documents\TabCMD\view19.png" 

copy "C:\Users\srobinson\Documents\TabCMD\view18.png" "C:\Users\srobinson\Documents\TabCMD\view20.png" 

tabcmd get "/views/CompanyKPI/ConsumerEngagement.png" -f "C:\Users\srobinson\Documents\TabCMD\view21.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view21.png" "C:\Users\srobinson\Documents\TabCMD\view22.png" 

tabcmd get "/views/CompanyKPI/LawyerEngagement.png" -f "C:\Users\srobinson\Documents\TabCMD\view23.png" --timeout 500

copy "C:\Users\srobinson\Documents\TabCMD\view23.png" "C:\Users\srobinson\Documents\TabCMD\view24.png" 

tabcmd get "/views/CompanyKPI/Monetization.png" -f "C:\Users\srobinson\Documents\TabCMD\view25.png" --timeout 500

tabcmd get "/views/UserActivityMetrics/WeeklySessionMetrics.png" -f "C:\Users\srobinson\Documents\TabCMD\view26.png" --timeout 500

tabcmd logout

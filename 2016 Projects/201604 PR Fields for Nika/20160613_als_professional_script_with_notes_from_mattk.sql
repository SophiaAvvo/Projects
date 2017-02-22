/* if they register, they show up in the provider table */

select  pro.id as professional_id
        , p.id as provider_id
        , concat(pro.firstname, ' ', pro.lastname) as lawyer_name
        , fully_functional as enrolled -- W9, bank acccount, and mobile are submitted and approved
        , case when ifnull(num_non_advisor_services_selected,0) > 0 then 1 else 0 end as non_advisor_services_selected
        , case when num_advisor_services_selected > 0 then 1 else 0 end as offering_advisor
        , case when fully_functional = 1 and (ifnull(num_non_advisor_services_selected,0) + ifnull(num_advisor_services_selected,0)) > 0 then 1 else 0 end as ready_to_transact
        , case when fully_functional = 1 and ifnull(num_advisor_services_selected,0) > 0 and ifnull(num_non_advisor_services_selected,0) = 0 then 1 else 0 end as rtt_advisor_only
        , case when fully_functional = 1 and ifnull(num_non_advisor_services_selected,0) > 0 then 1 else 0 end as rtt_non_advisor_services
        , p.accepting_sessions as notifications_enabled
        , ifnull(num_non_advisor_services_selected,0) as num_non_advisor_services_selected
        , case when p.phone_number_confirmed_at is not null then '1' else '0' end as mobile_number_confirmed
        , case when b.verification_status is null then 'Not on file' else b.verification_status end as bank_account_status
        , case
            when w.id is not null and (w.name is null or w.name = '') then 'W9 name not filled out'
            when w.id is not null and (w.name is not null and w.name != '') then 'W9 filled out'
            else 'W9 not filled out'
            end as w9_compliance
        , date(date_sub(p.created_at, interval 8 hour)) as registration_date
        , ifnull(
            case
            when b.verification_status != 'verified' or p.phone_number_confirmed_at is null then 'Bank/w9/mobile not filled out'
            when b.updated_at > w.w9_effective_date then date(b.updated_at)
            else date(date_sub(w.w9_effective_date, interval 8 hour))
            end
       , 'Bank/w9 not filled out') as enrollment_date
       , ifnull(po.first_pls_selected_services_date, 'No services selected') as first_pls_selected_services_date  -- presence of a first date means they have sold a PLS service

from providers p
       left join professionals pro on p.professional_id = pro.id

       left join (
         select provider_id, count(distinct offer_id) as num_non_advisor_services_selected
         from provider_offers
         join offers on provider_offers.offer_id = offers.id
         join packages on offers.package_id = packages.id
         where approved = 1 and capable = 1 and opted_in = 1 and packages.advisor = 0
         group by 1
       ) non_advisor_services on p.id = non_advisor_services.provider_id

       left join (
         select provider_id, count(distinct offer_id) as num_advisor_services_selected
         from provider_offers
         join offers on provider_offers.offer_id = offers.id
         join packages on offers.package_id = packages.id
         where approved = 1 and capable = 1 and opted_in = 1 and packages.advisor = 1
         group by 1
       ) advisor_services on p.id = advisor_services.provider_id

       left join (
         select ba.id, ba.provider_id, ba.verification_status, ba.updated_at
         from bank_accounts ba
         where ba.active = 1
       ) b on p.id = b.provider_id

       left join (
		 select w.id, w.provider_id, w.name, w.effective_date as w9_effective_date
        from w9s w
        inner join (
          select provider_id, max(effective_date) as latest_effective_date from w9s group by 1
        ) latest_form on w.effective_date = latest_form.latest_effective_date and w.provider_id = latest_form.provider_id
       ) w on p.id = w.provider_id
       left join (
         select provider_id, min(date(date_sub(provider_offers.updated_at, interval 8 hour))) as first_pls_selected_services_date
         from provider_offers
         join offers on provider_offers.offer_id = offers.id
         join packages on offers.package_id = packages.id
         where packages.advisor = 1 and opted_in = 1 group by 1
       ) po on p.id = po.provider_id
	   
	   -- to get delivered ALS transactions, join to advice_sessions
	   -- join offer_id to ocato_offers, then join ocato_offers to ocato_packages
-- start with providers table, filter on either "enabled" (approved by us) or "accepting sessions" (attorney's choice)
-- opted in means that they've marked a specific PACKAGE
-- avvo approved means that we are willing to let them be a provider

        where test_provider = 0;
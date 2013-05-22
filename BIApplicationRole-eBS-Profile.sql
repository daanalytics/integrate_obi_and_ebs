--
-- Lookup Type - XXBI_SECURITY_PROFILE
--

select t.lookup_type
     , t.meaning
     , a.application_name
     , t.description
  from applsys.fnd_lookup_types_tl t
     , applsys.fnd_lookup_types b
     , applsys.fnd_application_tl a
 where b.lookup_type = t.lookup_type
   and b.security_group_id = t.security_group_id
   and b.view_application_id = t.view_application_id
   and a.application_id = b.application_id
   and b.lookup_type = '&XXBI_SECURITY_PROFILE'
   and t.language = '&LANGUAGE'
   and a.language = '&LANGUAGE'
;

--
-- Lookup Values - XXBI_SECURITY_PROFILE
--

select flv.lookup_code
,      flv.meaning
,      flv.description
from   applsys.fnd_lookup_values flv
where  lookup_type = '&XXBI_SECURITY_PROFILE'
and    flv.language = '&LANGUAGE'
and    trunc(sysdate) >= trunc(flv.start_date_active)
and    trunc(sysdate) < nvl(trunc(flv.end_date_active), trunc(sysdate) +1)
;

--
-- Profile - XXBI_SECURITY_PROFILE
--

select fpo.profile_option_name
,      a.application_name
,      fpotl.user_profile_option_name
,      fpotl.description
from   applsys.fnd_profile_options fpo
     , applsys.fnd_profile_options_tl fpotl
     , applsys.fnd_application_tl a
where  fpotl.profile_option_name = fpo.profile_option_name
  and  a.application_id = fpo.application_id
  and  a.language = fpotl.language
  and  fpo.profile_option_name = '&XXBI_SECURITY_PROFILE' 
  and  fpotl.language = '&LANGUAGE'
;

--
-- Profile  (SQL Validation)- XXBI_SECURITY_PROFILE
--

SQL="SELECT MEANING \"BI Security Profile\", LOOKUP_CODE
into :visible_option_value,
:profile_option_value
from   applsys.fnd_lookup_values fl
where  fl.lookup_type = 'Enter Lookup Type here'    
and    fl.language = 'Enter Language here'
and    trunc(sysdate) >= trunc(fl.start_date_active)
and    trunc(sysdate) <nvl(trunc(fl.end_date_active), trunc(sysdate) + 1)"
COLUMN="\"BI Security Profile\"(10)"

--
-- Profile - XXBI_SECURITY_PROFILE
--

-- Site Level Default

select fpov.profile_option_value bi_type_gebruiker_site_level
  from apps.fnd_profile_options_vl fpovl
     , applsys.fnd_profile_option_values fpov
     , applsys.fnd_profile_options fpo
     , applsys.fnd_profile_options_tl fpotl
 where fpov.profile_option_id = fpovl.profile_option_id
   and fpo.profile_option_id = fpov.profile_option_id
   and fpotl.profile_option_name = fpo.profile_option_name
   and fpov.level_id = 10001 -- Site
   and fpotl.user_profile_option_name = '&XXBI_SECURITY_PROFILE'
   and fpotl.language = '&LANGUAGE'
;

-- Responsibility Level Specific

select fr.responsibility_id
     , fr.responsibility_name
     , fpov.profile_option_value bi_type_gebruiker_resp_level
  from apps.fnd_responsibility_vl fr
     , applsys.fnd_profile_option_values fpov
     , applsys.fnd_profile_options fpo
     , applsys.fnd_profile_options_tl fpotl
 where fpov.level_value = fr.responsibility_id
   and fpo.profile_option_id = fpov.profile_option_id
   and fpotl.profile_option_name = fpo.profile_option_name
   and fpov.level_id = 10003 -- Responsibility
   and fpotl.user_profile_option_name  = '&XXBI_SECURITY_PROFILE'
   and fpotl.language = '&LANGUAGE'

--
-- Oracle BI Initialization Block: GetApplicationRoles
--

select NVL ( rl.bi_sec_profile_resp_level
                       , sl.bi_sec_profile_site_level ) bi_type_gebruiker
             from ( select fpov.profile_option_id
                         , fpotl.language
                         , fpov.profile_option_value
                                                 bi_sec_profile_resp_level
                     from applsys.fnd_responsibility fr
                        , applsys.fnd_profile_option_values fpov
                        , applsys.fnd_profile_options fpo
                        , applsys.fnd_profile_options_tl fpotl
                    where fpov.level_value = fr.responsibility_id
                      and fpo.profile_option_id = fpov.profile_option_id
                      and fpotl.profile_option_name = fpo.profile_option_name
                      and fpov.level_id = 10003
                      and fpo.profile_option_name = '&XXBI_SECURITY_PROFILE'
                      and fpotl.language = '&LANGUAGE'
                      and fr.responsibility_id = fnd_global.resp_id
                      and fr.application_id = fnd_global.resp_appl_id
                                               ) rl
                , ( select fpov.profile_option_id
                         , fpotl.language
                         , fpov.profile_option_value
                                                 bi_sec_profile_site_level
                     from applsys.fnd_profile_option_values fpov
                        , applsys.fnd_profile_options fpo
                        , applsys.fnd_profile_options_tl fpotl
                    where fpo.profile_option_id = fpov.profile_option_id
                      and fpotl.profile_option_name = fpo.profile_option_name
                      and fpov.level_id = 10001
                      and fpo.profile_option_name = '&XXBI_SECURITY_PROFILE'
                      and fpotl.language = '&LANGUAGE' ) sl
            where sl.language = rl.language(+)
              and sl.profile_option_id = rl.profile_option_id(+) 
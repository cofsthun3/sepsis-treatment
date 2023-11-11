--culture
select subject_id, hadm_id, icustay_id,  UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid
from `physionet-data.mimiciii_clinical.chartevents`
where itemid in (6035,3333,938,941,942,4855,6043,2929,225401,225437,225444,225451,225454,225814,225816,225817,225818,225722,225723,225724,225725,225726,225727,225728,225729,225730,225731,225732,225733,227726,70006,70011,70012,70013,70014,70016,70024,70037,70041,225734,225735,225736,225768,70055,70057,70060,70063,70075,70083,226131,80220)
order by subject_id, hadm_id, charttime;

--microbio
select subject_id, hadm_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, UNIX_SECONDS(CAST(chartDATE AS TIMESTAMP)) as chartdate
from `physionet-data.mimiciii_clinical.microbiologyevents`;


--abx
select hadm_id, icustay_id, UNIX_SECONDS(CAST(startdate AS TIMESTAMP)) as startdate, UNIX_SECONDS(CAST(enddate AS TIMESTAMP)) as enddate
from `physionet-data.mimiciii_clinical.prescriptions`
where gsn in ('002542','002543','007371','008873','008877','008879','008880','008935','008941','008942','008943','008944','008983','008984','008990','008991','008992','008995','008996','008998','009043','009046','009065','009066','009136','009137','009162','009164','009165','009171','009182','009189','009213','009214','009218','009219','009221','009226','009227','009235','009242','009263','009273','009284','009298','009299','009310','009322','009323','009326','009327','009339','009346','009351','009354','009362','009394','009395','009396','009509','009510','009511','009544','009585','009591','009592','009630','013023','013645','013723','013724','013725','014182','014500','015979','016368','016373','016408','016931','016932','016949','018636','018637','018766','019283','021187','021205','021735','021871','023372','023989','024095','024194','024668','025080','026721','027252','027465','027470','029325','029927','029928','037042','039551','039806','040819','041798','043350','043879','044143','045131','045132','046771','047797','048077','048262','048266','048292','049835','050442','050443','051932','052050','060365','066295','067471')
order by hadm_id, icustay_id;

--demog
select ad.subject_id, ad.hadm_id, i.icustay_id
,UNIX_SECONDS(CAST(admittime AS TIMESTAMP)) as admittime
, UNIX_SECONDS(CAST(dischtime AS TIMESTAMP)) as dischtime,
ROW_NUMBER() over (partition by ad.subject_id order by i.intime asc) as adm_order, case when i.first_careunit='NICU' then 5 when i.first_careunit='SICU' then 2 when i.first_careunit='CSRU' then 4 when i.first_careunit='CCU' then 6 when i.first_careunit='MICU' then 1 when i.first_careunit='TSICU' then 3 end as unit
,UNIX_SECONDS(CAST(intime AS TIMESTAMP)) as intime
,UNIX_SECONDS(CAST(outtime AS TIMESTAMP)) as outtime, i.los
,TIMESTAMP_DIFF(CAST(i.intime AS TIMESTAMP), CAST(p.dob AS TIMESTAMP), SECOND) /86400 as age
 --,EXTRACT(EPOCH FROM (i.intime-p.dob)::INTERVAL)/86400 as age
 ,UNIX_SECONDS(CAST(dob AS TIMESTAMP)) as dob, UNIX_SECONDS(CAST(dod AS TIMESTAMP)) as dod,
 p.expire_flag,  case when p.gender='M' then 1 when p.gender='F' then 2 end as gender,
CAST(TIMESTAMP_DIFF(CAST(p.dod AS TIMESTAMP), CAST(ad.dischtime AS TIMESTAMP), SECOND) <=24*3600 as int )as morta_hosp,  --died in hosp if recorded DOD is close to hosp discharge
CAST(TIMESTAMP_DIFF(CAST(p.dod AS TIMESTAMP), CAST(i.intime AS TIMESTAMP), SECOND) <=90*24*3600 as int )as morta_90,

 --CAST(extract(epoch from age(p.dod,ad.dischtime))<=24*3600  as int )as morta_hosp,  --died in hosp if recorded DOD is close to hosp discharge
 --CAST(extract(epoch from age(p.dod,i.intime))<=90*24*3600  as int )as morta_90,
 congestive_heart_failure+cardiac_arrhythmias+valvular_disease+pulmonary_circulation+peripheral_vascular+hypertension+paralysis+other_neurological+chronic_pulmonary+diabetes_uncomplicated+diabetes_complicated+hypothyroidism+renal_failure+liver_disease+peptic_ulcer+aids+lymphoma+metastatic_cancer+solid_tumor+rheumatoid_arthritis+coagulopathy+obesity	+weight_loss+fluid_electrolyte+blood_loss_anemia+	deficiency_anemias+alcohol_abuse+drug_abuse+psychoses+depression as elixhauser
from `physionet-data.mimiciii_clinical.admissions` ad, `physionet-data.mimiciii_clinical.icustays` i, `physionet-data.mimiciii_clinical.patients` p, `cse6250-project-404701.mimic.elixhauser_quan` elix
where ad.hadm_id=i.hadm_id and p.subject_id=i.subject_id and elix.hadm_id=ad.hadm_id
order by subject_id asc, intime asc;

--ce010000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=200000 and icustay_id< 210000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce1000020000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=210000 and icustay_id< 220000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce2000030000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=220000 and icustay_id< 230000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce3000040000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=230000 and icustay_id< 240000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce4000050000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=240000 and icustay_id< 250000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce5000060000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=250000 and icustay_id< 260000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce6000070000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=260000 and icustay_id< 270000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce7000080000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=270000 and icustay_id< 280000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce8000090000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=280000 and icustay_id< 290000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;

--ce90000100000
select distinct icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid,
case when value = 'None' then 0.0 when value = 'Ventilator' then 1.0 when value='Cannula' then 2.0 when value = 'Nasal Cannula' then 2.0 when value = 'Face Tent' then 3.0 when value = 'Aerosol-Cool' then 4.0 when value = 'Trach Mask' then 5.0 when value = 'Hi Flow Neb' then 6.0 when value = 'Non-Rebreather' then 7.0 when value = '' then 8.0  when value = 'Venti Mask' then 9.0 when value = 'Medium Conc Mask' then 10.0 else valuenum end as valuenum
from `physionet-data.mimiciii_clinical.chartevents` where icustay_id>=290000 and icustay_id< 300000 and value is not null and itemid in  (467, 470,471,223834,227287,194,224691,226707,226730	,581,	580,	224639	,226512,198,228096	,211,220045,220179,225309,6701,	6	,227243,	224167,	51,	455, 220181,	220052,	225312,	224322,	6702,	443	,52,	456,8368	,8441,	225310	,8555	,8440,220210	,3337	,224422	,618,	3603,	615,220277,	646,	834,3655,	223762	,223761,	678,220074	,113,492,491,8448,116,	1372	,1366	,228368	,228177,626,223835,3420,160,	727,190,220339	,506	,505,	224700,224686,224684,684,	224421,224687,	450	,448	,445,224697,444,224695,	535,224696	,543,3083,	2566	,654	,3050,681,	2311)
order by icustay_id, charttime ;


--labs_ce
select icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid, valuenum
from `physionet-data.mimiciii_clinical.chartevents`
where valuenum is not null and icustay_id is not null and itemid in  (829,	1535,	227442,	227464,	4195	,3726	,3792,837,	220645,	4194,	3725,	3803	,226534,	1536,	4195,	3726,788,	220602,	1523,	4193,	3724	,226536,	3747,225664,	807,	811,	1529,	220621,	226537,	3744,781,	1162,	225624,	3737,791,	1525,	220615,	3750,821,	1532,	220635,786,	225625,	1522,	3746,816,	225667,	3766,777,	787,770,	3801,769,	3802,1538,	848,	225690,	803,	1527,	225651,	3807,	1539,	849,	772,	1521,	227456,	3727,	227429,	851,227444,	814,	220228,	813,	220545,	3761,	226540,	4197,	3799	,1127,	1542,	220546,	4200,	3834,	828,	227457,	3789,825,	1533,	227466,	3796,824,	1286,1671,	1520,	768,220507	,815,	1530,	227467,	780,	1126,	3839,	4753,779,	490,	3785,	3838,	3837,778,	3784,	3836,	3835,776,	224828,	3736,	4196,	3740,	74,225668,1531,227443,1817,	228640,823,	227686)
order by icustay_id, charttime, itemid;

--labs_le
select xx.icustay_id, UNIX_SECONDS(CAST(f.charttime AS TIMESTAMP)) as timestp, f.itemid, f.valuenum
from(
select subject_id, hadm_id, icustay_id, intime, outtime
from `physionet-data.mimiciii_clinical.icustays`
group by subject_id, hadm_id, icustay_id, intime, outtime
) as xx inner join  `physionet-data.mimiciii_clinical.labevents` as f on f.hadm_id=xx.hadm_id
and f.charttime>= DATE_SUB(xx.intime, interval 1 DAY) and f.charttime<= DATE_ADD(xx.outtime, interval 1 DAY)
and f.itemid in  (50971,50822,50824,50806,50931,51081,50885,51003,51222,50810,51301,50983,50902,50809,51006,50912,50960,50893,50808,50804,50878,50861,51464,50883,50976,50862,51002,50889,50811,51221,51279,51300,51265,51275,51274,51237,50820,50821,50818,50802,50813,50882,50803)
and valuenum is not null
order by f.hadm_id, timestp, f.itemid;

--uo
select icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, itemid, value
from `physionet-data.mimiciii_clinical.outputevents`
where icustay_id is not null and value is not null and itemid in (40055	,43175	,40069,	40094	,40715	,40473	,40085,	40057,	40056	,40405	,40428,	40096,	40651,226559	,226560	,227510	,226561	,227489	,226584,	226563	,226564	,226565	,226557	,226558)
order by icustay_id, charttime, itemid;

--preadm_uo
select distinct oe.icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, oe.itemid, oe.value , TIMESTAMP_DIFF(ic.intime, oe.charttime, MINUTE) as datediff_minutes
from `physionet-data.mimiciii_clinical.outputevents` oe, `physionet-data.mimiciii_clinical.icustays` ic
where oe.icustay_id=ic.icustay_id and itemid in (	40060,	226633)
order by icustay_id, charttime, itemid;

--fluid_mv
with t1 as
(
select icustay_id, UNIX_SECONDS(CAST(starttime AS TIMESTAMP)) as starttime, UNIX_SECONDS(CAST(endtime AS TIMESTAMP)) as endtime, itemid, amount, rate,
case when itemid in (30176,30315) then amount *0.25
when itemid in (30161) then amount *0.3
when itemid in (30020,30015,225823,30321,30186,30211, 30353,42742,42244,225159) then amount *0.5 --
when itemid in (227531) then amount *2.75
when itemid in (30143,225161) then amount *3
when itemid in (30009,220862) then amount *5
when itemid in (30030,220995,227533) then amount *6.66
when itemid in (228341) then amount *8
else amount end as tev -- total equivalent volume
from `physionet-data.mimiciii_clinical.inputevents_mv`
-- only real time items !!
where icustay_id is not null and amount is not null and itemid in (225158,225943,226089,225168,225828,225823,220862,220970,220864,225159,220995,225170,225825,227533,225161,227531,225171,225827,225941,225823,225825,225941,225825,228341,225827,30018,30021,30015,30296,30020,30066,30001,30030,30060,30005,30321,3000630061,30009,30179,30190,30143,30160,30008,30168,30186,30211,30353,30159,30007,30185,30063,30094,30352,30014,30011,30210,46493,45399,46516,40850,30176,30161,30381,30315,42742,30180,46087,41491,30004,42698,42244)
)


select icustay_id, starttime, endtime, itemid, round(cast(amount as numeric),3) as amount,round(cast(rate as numeric),3) as rate,round(cast(tev as numeric),3) as tev -- total equiv volume
from t1
order by icustay_id, starttime, itemid;


--fluid_cv
with t1 as
(
select icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP))  as charttime, itemid, amount,
case when itemid in (30176,30315) then amount *0.25
when itemid in (30161) then amount *0.3
when itemid in (30020,30321, 30015,225823,30186,30211,30353,42742,42244,225159,225159,225159) then amount *0.5
when itemid in (227531) then amount *2.75
when itemid in (30143,225161) then amount *3
when itemid in (30009,220862) then amount *5
when itemid in (30030,220995,227533) then amount *6.66
when itemid in (228341) then amount *8
else amount end as tev -- total equivalent volume
from `physionet-data.mimiciii_clinical.inputevents_cv`
-- only RT itemids
where amount is not null and itemid in (225158,225943,226089,225168,225828,225823,220862,220970,220864,225159,220995,225170,225825,227533,225161,227531,225171,225827,225941,225823,225825,225941,225825,228341,225827,30018,30021,30015,30296,30020,30066,30001,30030,30060,30005,30321,3000630061,30009,30179,30190,30143,30160,30008,30168,30186,30211,30353,30159,30007,30185,30063,30094,30352,30014,30011,30210,46493,45399,46516,40850,30176,30161,30381,30315,42742,30180,46087,41491,30004,42698,42244)
order by icustay_id, charttime, itemid
)


select icustay_id, charttime, itemid, round(cast(amount as numeric),3) as amount, round(cast(tev as numeric),3) as tev -- total equivalent volume
from t1;

--preadm_fluid
with mv as
(
select ie.icustay_id, sum(ie.amount) as sum
from `physionet-data.mimiciii_clinical.inputevents_mv` ie, `physionet-data.mimiciii_clinical.d_items` ci
where ie.itemid=ci.itemid and ie.itemid in (30054,30055,30101,30102,30103,30104,30105,30108,226361,226363,226364,226365,226367,226368,226369,226370,226371,226372,226375,226376,227070,227071,227072)
group by icustay_id
), cv as
(
select ie.icustay_id, sum(ie.amount) as sum
from `physionet-data.mimiciii_clinical.inputevents_cv` ie, `physionet-data.mimiciii_clinical.d_items` ci
where ie.itemid=ci.itemid and ie.itemid in (30054,30055,30101,30102,30103,30104,30105,30108,226361,226363,226364,226365,226367,226368,226369,226370,226371,226372,226375,226376,227070,227071,227072)
group by icustay_id
)


select pt.icustay_id,
case when mv.sum is not null then mv.sum
when cv.sum is not null then cv.sum
else null end as inputpreadm
from `physionet-data.mimiciii_clinical.icustays` pt
left outer join mv
on mv.icustay_id=pt.icustay_id
left outer join cv
on cv.icustay_id=pt.icustay_id
order by icustay_id;

--vaso_mv
select icustay_id, itemid, UNIX_SECONDS(CAST(starttime AS TIMESTAMP)) as starttime, UNIX_SECONDS(CAST(endtime AS TIMESTAMP)) as endtime, -- rate, -- ,rateuom,
case when itemid in (30120,221906,30047) and rateuom='mcg/kg/min' then round(cast(rate as numeric),3)  -- norad
when itemid in (30120,221906,30047) and rateuom='mcg/min' then round(cast(rate/80 as numeric),3)  -- norad
when itemid in (30119,221289) and rateuom='mcg/kg/min' then round(cast(rate as numeric),3) -- epi
when itemid in (30119,221289) and rateuom='mcg/min' then round(cast(rate/80 as numeric),3) -- epi
when itemid in (30051,222315) and rate > 0.2 then round(cast(rate*5/60  as numeric),3) -- vasopressin, in U/h
when itemid in (30051,222315) and rateuom='units/min' then round(cast(rate*5 as numeric),3) -- vasopressin
when itemid in (30051,222315) and rateuom='units/hour' then round(cast(rate*5/60 as numeric),3) -- vasopressin
when itemid in (30128,221749,30127) and rateuom='mcg/kg/min' then round(cast(rate*0.45 as numeric),3) -- phenyl
when itemid in (30128,221749,30127) and rateuom='mcg/min' then round(cast(rate*0.45 / 80 as numeric),3) -- phenyl
when itemid in (221662,30043,30307) and rateuom='mcg/kg/min' then round(cast(rate*0.01 as numeric),3)  -- dopa
when itemid in (221662,30043,30307) and rateuom='mcg/min' then round(cast(rate*0.01/80 as numeric),3) else null end as rate_std-- dopa
from `physionet-data.mimiciii_clinical.inputevents_mv`
where itemid in (30128,30120,30051,221749,221906,30119,30047,30127,221289,222315,221662,30043,30307) and rate is not null and statusdescription <> 'Rewritten'
order by icustay_id, itemid, starttime;


--vaso_cv
select icustay_id,  itemid, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime, -- rate, -- rateuom,
case when itemid in (30120,221906,30047) and rateuom='mcgkgmin' then round(cast(rate as numeric),3) -- norad
when itemid in (30120,221906,30047) and rateuom='mcgmin' then round(cast(rate/80 as numeric),3)  -- norad
when itemid in (30119,221289) and rateuom='mcgkgmin' then round(cast(rate as numeric),3) -- epi
when itemid in (30119,221289) and rateuom='mcgmin' then round(cast(rate/80 as numeric),3) -- epi
when itemid in (30051,222315) and rate > 0.2 then round(cast(rate*5/60  as numeric),3) -- vasopressin, in U/h
when itemid in (30051,222315) and rateuom='Umin' and rate < 0.2 then round(cast(rate*5  as numeric),3) -- vasopressin
when itemid in (30051,222315) and rateuom='Uhr' then round(cast(rate*5/60  as numeric),3) -- vasopressin
when itemid in (30128,221749,30127) and rateuom='mcgkgmin' then round(cast(rate*0.45  as numeric),3) -- phenyl
when itemid in (30128,221749,30127) and rateuom='mcgmin' then round(cast(rate*0.45 / 80  as numeric),3) -- phenyl
when itemid in (221662,30043,30307) and rateuom='mcgkgmin' then round(cast(rate*0.01   as numeric),3) -- dopa
when itemid in (221662,30043,30307) and rateuom='mcgmin' then round(cast(rate*0.01/80  as numeric),3) else null end as rate_std-- dopa
-- case when rateuom='mcgkgmin' then 1 when rateuom='mcgmin' then 2 end as uom
from `physionet-data.mimiciii_clinical.inputevents_cv`
where itemid in (30128,30120,30051,221749,221906,30119,30047,30127,221289,222315,221662,30043,30307) and rate is not null
order by icustay_id, itemid, charttime;




-- mechvent
select
    icustay_id, UNIX_SECONDS(CAST(charttime AS TIMESTAMP)) as charttime    -- case statement determining whether it is an instance of mech vent
    , max(
      case
        when itemid is null or value is null then 0 -- can't have null values
        when itemid = 720 and value != 'Other/Remarks' THEN 1  -- VentTypeRecorded
        when itemid = 467 and value = 'Ventilator' THEN 1 -- O2 delivery device == ventilator
        when itemid in
          (
          445, 448, 449, 450, 1340, 1486, 1600, 224687 -- minute volume
          , 639, 654, 681, 682, 683, 684,224685,224684,224686 -- tidal volume
          , 218,436,535,444,459,224697,224695,224696,224746,224747 -- High/Low/Peak/Mean/Neg insp force ("RespPressure")
          , 221,1,1211,1655,2000,226873,224738,224419,224750,227187 -- Insp pressure
          , 543 -- PlateauPressure
          , 5865,5866,224707,224709,224705,224706 -- APRV pressure
          , 60,437,505,506,686,220339,224700 -- PEEP
          , 3459 -- high pressure relief
          , 501,502,503,224702 -- PCV
          , 223,667,668,669,670,671,672 -- TCPCV
          , 157,158,1852,3398,3399,3400,3401,3402,3403,3404,8382,227809,227810 -- ETT
          , 224701 -- PSVlevel
          )
          THEN 1
        else 0
      end
      ) as MechVent
      , max(
        case when itemid is null or value is null then 0
          when itemid = 640 and value = 'Extubated' then 1
          when itemid = 640 and value = 'Self Extubation' then 1
        else 0
        end
        )
        as Extubated
      , max(
        case when itemid is null or value is null then 0
          when itemid = 640 and value = 'Self Extubation' then 1
        else 0
        end
        )
        as SelfExtubated


  from `physionet-data.mimiciii_clinical.chartevents` ce
  where value is not null
  and itemid in
  (
      640 -- extubated
      , 720 -- vent type
      , 467 -- O2 delivery device
      , 445, 448, 449, 450, 1340, 1486, 1600, 224687 -- minute volume
      , 639, 654, 681, 682, 683, 684,224685,224684,224686 -- tidal volume
      , 218,436,535,444,459,224697,224695,224696,224746,224747 -- High/Low/Peak/Mean/Neg insp force ("RespPressure")
      , 221,1,1211,1655,2000,226873,224738,224419,224750,227187 -- Insp pressure
      , 543 -- PlateauPressure
      , 5865,5866,224707,224709,224705,224706 -- APRV pressure
      , 60,437,505,506,686,220339,224700 -- PEEP
      , 3459 -- high pressure relief
      , 501,502,503,224702 -- PCV
      , 223,667,668,669,670,671,672 -- TCPCV
      , 157,158,1852,3398,3399,3400,3401,3402,3403,3404,8382,227809,227810 -- ETT
      , 224701 -- PSVlevel
  )
  group by icustay_id, charttime;

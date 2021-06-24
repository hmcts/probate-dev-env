psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0501',now(),'miscellaneous',501,'FixedFee','family','probate registry','Caveat',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 3)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description,status,valid_from,valid_to,version,amount_id,fee_id,direction_type,fee_order_name,memo_line,natural_account_code,si_ref_id,statutory_instrument,approved_by,author) VALUES ('Application for the entry or extension of a caveat',1,'2011-04-03 00:00:00.000',NULL,1,(SELECT MAX( id ) FROM amount a ),(SELECT MAX(id) from fee),'cost recovery','Non-Contentious Probate Fees','RECEIPT OF FEES - Family misc probate','4481102173','4','2011 No 588 ','126175','126172')";

psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0500',now(),'issue',500,'FixedFee','family','probate registry','SAL5K',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 0)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description, status, valid_from, version, amount_id, fee_id, direction_type, fee_order_name, memo_line, natural_account_code, si_ref_id, statutory_instrument) VALUES ('VH - added to fix local func tests issue', 1, '2021-06-22 00:00:00', 1, (select id from flat_amount where amount = 0 LIMIT 1), (SELECT id FROM fee WHERE keyword = 'SAL5K' AND service = 'probate' AND channel_type= 'default' AND jurisdiction1 = 'family' AND jurisdiction2 = 'probate registry' LIMIT 1), 'enhanced', 'Non-Contentious Probate Fees', 'Non Personal Application for grant of Probate', 4481102158, 1, '2011 No. 588 (L. 4)')";
echo "...insert fees completed"

echo "Updating Fees keyword, and amounts..."
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'GrantWill' WHERE code = 'FEE0003'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'PA' WHERE code = 'FEE0226'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'PAL5K' WHERE id = 1";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'SA' WHERE code = 'FEE0219'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE volume_amount SET amount = '1.5' WHERE id = (SELECT id FROM amount WHERE amount_type = 'VolumeAmount' ORDER BY id LIMIT 1)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE flat_amount SET amount = '1.5' WHERE id = '1'";
echo "...Updated fees"

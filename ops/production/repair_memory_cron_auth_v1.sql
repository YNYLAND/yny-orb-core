-- Production-only operational repair for YNY PLATFORMA.
-- No plaintext secret is stored: workers receive the Vault secret at execution time.

select cron.alter_job(
  job_id := 1,
  command := $cmd$
    select net.http_post(
      url := 'https://dcjsuhtwncyhwensjbdt.supabase.co/functions/v1/memory-summary-builder',
      headers := jsonb_build_object(
        'Content-Type','application/json',
        'x-orb-memory-secret',(
          select decrypted_secret
          from vault.decrypted_secrets
          where name='orb_memory_internal_secret'
        )
      ),
      body := jsonb_build_object(
        'min_messages',8,
        'max_messages_to_analyze',30
      ),
      timeout_milliseconds := 10000
    );
  $cmd$
);

select cron.alter_job(
  job_id := 2,
  command := $cmd$
    select net.http_post(
      url := 'https://dcjsuhtwncyhwensjbdt.supabase.co/functions/v1/profile-memory-builder',
      headers := jsonb_build_object(
        'Content-Type','application/json',
        'x-orb-memory-secret',(
          select decrypted_secret
          from vault.decrypted_secrets
          where name='orb_memory_internal_secret'
        )
      ),
      body := jsonb_build_object('limit',50),
      timeout_milliseconds := 10000
    );
  $cmd$
);

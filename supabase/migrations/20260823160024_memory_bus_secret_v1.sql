do $$
begin
  if not exists (
    select 1 from vault.secrets where name = 'orb_memory_internal_secret'
  ) then
    perform vault.create_secret(
      encode(gen_random_bytes(32), 'hex'),
      'orb_memory_internal_secret',
      'Internal authentication secret for Orb memory background workers'
    );
  end if;
end $$;

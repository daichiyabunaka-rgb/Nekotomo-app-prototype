-- ============================================================
-- 0005_nekotomo_cats: ニーアキャット（猫とも！）の保護猫・迷い猫
-- 対象: 共有Supabaseプロジェクト（追加のみ・非破壊・トランザクション）
--
-- 内容:
--   1. protected_cats テーブル（犬とも！の protected_dogs と同じ設計）
--      - 譲渡・里親探しは行わない（自治体・保護団体の正式な手続きへ誘導）
--      - reporter_id の FK はマルチテナント化後のスキーマに合わせ
--        auth.users を参照する（profiles は (id, app_id) 複合PKのため）
--   2. 投稿写真バケット protected-cat-photos（公開・ユーザーごとUUID名前空間）
--      - アップロードパスは <uid>/nekotomo/cat_photo_*.jpg
--      - （アプリアイコン等は犬とも！と共通の icons バケットを使う）
--
-- 前提: 0002_multiapp.sql（app_id列・profiles複合PK・FKのauth.users張替え）
--       が適用済みであること。0003〜0004 は本ファイルと依存しないが、
--       番号順に適用する運用（提案006）に従うこと。
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 1. protected_cats テーブル
-- ------------------------------------------------------------
create table if not exists public.protected_cats (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('protected', 'lost')),
  cat_description text not null,
  area_name text not null,
  detail text not null default '',
  photo_path text,                           -- 投稿写真（Storage 'protected-cat-photos' バケットの公開URL）
  location_geohash text not null,
  resolved boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists protected_cats_geohash_idx
  on public.protected_cats (location_geohash);

alter table public.protected_cats enable row level security;

-- ポリシーの重複対策
drop policy if exists "保護猫迷い猫は誰でも閲覧可" on public.protected_cats;
drop policy if exists "保護猫登録は本人のみ" on public.protected_cats;
drop policy if exists "保護猫更新は本人のみ" on public.protected_cats;
drop policy if exists "保護猫削除は本人のみ" on public.protected_cats;

create policy "保護猫迷い猫は誰でも閲覧可" on public.protected_cats
  for select using (true);
create policy "保護猫登録は本人のみ" on public.protected_cats
  for insert with check (auth.uid() = reporter_id);
create policy "保護猫更新は本人のみ" on public.protected_cats
  for update using (auth.uid() = reporter_id);
create policy "保護猫削除は本人のみ" on public.protected_cats
  for delete using (auth.uid() = reporter_id);

-- 保護猫テーブルの行はアカウント削除で消す
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  delete from public.community_members where user_id = auth.uid();
  delete from public.event_participants where user_id = auth.uid();
  delete from public.chat_room_members where user_id = auth.uid();
  delete from public.join_applications where applicant_id = auth.uid();
  delete from public.recruitments where host_id = auth.uid();
  delete from public.communities where owner_id = auth.uid();
  delete from public.categories where created_by = auth.uid();
  delete from public.blocks where blocker_id = auth.uid() or blocked_id = auth.uid();
  delete from public.reports where reporter_id = auth.uid();
  delete from public.catch_reports where reporter_id = auth.uid();
  delete from public.protected_dogs where reporter_id = auth.uid();
  delete from public.protected_cats where reporter_id = auth.uid();
  delete from public.profiles where id = auth.uid();

  delete from auth.users where id = auth.uid();
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- ------------------------------------------------------------
-- 2. 投稿写真バケット（公開）
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('protected-cat-photos', 'protected-cat-photos', true)
on conflict (id) do nothing;

-- ポリシーの重複対策
drop policy if exists "保護猫写真は公開読み取り可" on storage.objects;
drop policy if exists "認証ユーザーは自分の保護猫写真をアップロード可" on storage.objects;
drop policy if exists "認証ユーザーは自分の保護猫写真を削除可" on storage.objects;

-- 公開バケットなので誰でも閲覧可（一覧表示に必要）
create policy "保護猫写真は公開読み取り可" on storage.objects
  for select using (bucket_id = 'protected-cat-photos');

-- アップロードは認証ユーザー本人の名前空間（<uuid>/...）のみ
create policy "認証ユーザーは自分の保護猫写真をアップロード可" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'protected-cat-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "認証ユーザーは自分の保護猫写真を削除可" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'protected-cat-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

commit;

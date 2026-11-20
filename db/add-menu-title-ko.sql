ALTER TABLE MENU RENAME COLUMN IF EXISTS TITLE TO TITLE_EN;

SET @menu_title_ko_missing = NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND UPPER(TABLE_NAME) = 'MENU' AND COLUMN_NAME = 'TITLE_KO'
);

ALTER TABLE MENU ADD COLUMN IF NOT EXISTS TITLE_KO VARCHAR(255) NULL
    COMMENT 'Korean menu title with fallback to TITLE_EN' AFTER TITLE_EN;

ALTER TABLE MENU MODIFY COLUMN TITLE_KO VARCHAR(255) NULL
    COMMENT 'Korean menu title with fallback to TITLE_EN';

UPDATE MENU
SET TITLE_KO = CASE PATH
    WHEN '/user' THEN '사용자'
    WHEN '/profile' THEN '프로필'
    WHEN '/socialmedia' THEN '소셜 미디어'
    WHEN '/content' THEN '콘텐츠'
    WHEN '/article/list' THEN '글'
    WHEN '/category' THEN '카테고리'
    WHEN '/system' THEN '시스템'
    WHEN '/menu' THEN '메뉴'
END
WHERE @menu_title_ko_missing = 1 AND FLAG_DELETED = 'N' AND TITLE_KO IS NULL
  AND (PATH, TITLE_EN) IN (('/user', 'User'), ('/profile', 'Profile'), ('/socialmedia', 'Social Media'),
                        ('/content', 'Content'), ('/article/list', 'Article'), ('/category', 'Category'),
                        ('/system', 'System'), ('/menu', 'Menu'));

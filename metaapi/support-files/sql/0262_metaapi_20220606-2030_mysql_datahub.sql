/*
 * Tencent is pleased to support the open source community by making BK-BASE 蓝鲸基础平台 available.
 *
 * Copyright (C) 2021 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * BK-BASE 蓝鲸基础平台 is licensed under the MIT License.
 *
 * License for BK-BASE 蓝鲸基础平台:
 * --------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


SET NAMES utf8;
use bkdata_basic;

DROP PROCEDURE IF EXISTS schema_update;

DELIMITER <BKBASE_UBF>

CREATE PROCEDURE schema_update()
BEGIN

    DECLARE db VARCHAR(100);
    SET AUTOCOMMIT = 0;
    SELECT DATABASE() INTO db;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'dm_task_content_config' AND COLUMN_NAME = 'standard_content_id'
    ) THEN
        ALTER TABLE `dm_task_content_config` ADD COLUMN `standard_content_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标准内容id';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'dm_task_detail' AND COLUMN_NAME = 'standard_content_id'
    ) THEN
        ALTER TABLE `dm_task_detail` ADD COLUMN `standard_content_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标准内容id';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'storage_cluster_config' AND COLUMN_NAME = 'maintain_by_bkbase'
    ) THEN
        ALTER TABLE `storage_cluster_config` ADD COLUMN `maintain_by_bkbase` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '集群是否bkbase平台维护';
    END IF;

    COMMIT;
END <BKBASE_UBF>
DELIMITER ;
COMMIT;
CALL schema_update();

DROP PROCEDURE IF EXISTS schema_update;



-- 同步 meta库 --

SET NAMES utf8;
use bkdata_meta;

DROP PROCEDURE IF EXISTS schema_update;

DELIMITER <BKBASE_UBF>

CREATE PROCEDURE schema_update()
BEGIN

    DECLARE db VARCHAR(100);
    SET AUTOCOMMIT = 0;
    SELECT DATABASE() INTO db;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'dm_task_content_config' AND COLUMN_NAME = 'standard_content_id'
    ) THEN
        ALTER TABLE `dm_task_content_config` ADD COLUMN `standard_content_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标准内容id';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'dm_task_detail' AND COLUMN_NAME = 'standard_content_id'
    ) THEN
        ALTER TABLE `dm_task_detail` ADD COLUMN `standard_content_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标准内容id';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE TABLE_SCHEMA = db AND TABLE_NAME = 'storage_cluster_config' AND COLUMN_NAME = 'maintain_by_bkbase'
    ) THEN
        ALTER TABLE `storage_cluster_config` ADD COLUMN `maintain_by_bkbase` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '集群是否bkbase平台维护';
    END IF;

    COMMIT;
END <BKBASE_UBF>
DELIMITER ;
COMMIT;
CALL schema_update();

DROP PROCEDURE IF EXISTS schema_update;

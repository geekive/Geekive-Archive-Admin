package com.geekive.geekiveArchiveAdmin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;

@Mapper
public interface CommonMapper {
	public List<Map<String, Object>> selectAllMenu(Object object);
	public String selectSelectedMenuTitle(@Param("path") String path, @Param("korean") boolean korean);
	public String selectProfileImageUrlPath(GeekiveMap gMap);
}

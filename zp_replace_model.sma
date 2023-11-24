#include <amxmodx>
#include <reapi>
#include <hamsandwich>
#include <zombieplague>

new Trie: g_TrieModels;

new const FILE_PATH[] = "addons/amxmodx/configs/jbombmodels.ini";

// Название гранаты, под которую заточена граната джамп.
new const WEAPON_REF[] = "weapon_smokegrenade";

public plugin_precache() {
	@ReadFile();
}

public plugin_init() {
	register_plugin("[ZP 4.3] Jump Model For Zombie", "1.0", "ImmortalAmxx");
	
	RegisterHam(Ham_Item_Deploy, WEAPON_REF, "@HamHook_ItemDeploy_Post", true);
}

@HamHook_ItemDeploy_Post(WeaponId) {
	new UserId = get_member(WeaponId, m_pPlayer);
	
	if(!zp_get_user_zombie(UserId))
		return HAM_IGNORED;
	
	new ClassId = zp_get_user_zombie_class(UserId);
	
	new szClassId[10], szModelPah[256];
	num_to_str(ClassId, szClassId, charsmax(szClassId));
	
	if(TrieKeyExists(g_TrieModels, szClassId)) {
		TrieGetString(g_TrieModels, szClassId, szModelPah, charsmax(szModelPah));
		
		set_entvar(UserId, var_viewmodel, szModelPah);
	}

	return HAM_IGNORED;
}

@ReadFile() {
	new iFile, szData[256], szIndexZombie[5], szModelPah[256];
	
	iFile = fopen(FILE_PATH, "r");
	
	if(iFile) {
		g_TrieModels = TrieCreate();
	
		while(!feof(iFile)) {
			fgets(iFile, szData, charsmax(szData));
			trim(szData);
			
			if(!szData[0] || szData[0] == ';')
				continue;
				
			if(szData[0] == '"') {
				parse(szData,
					szIndexZombie, charsmax(szIndexZombie),
					szModelPah, charsmax(szModelPah)
				);
				
				precache_model(szModelPah);
				TrieSetString(g_TrieModels, szIndexZombie, szModelPah);
			}
		}
	
		fclose(iFile);
	}
}
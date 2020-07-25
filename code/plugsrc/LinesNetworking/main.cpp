// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include <unordered_map>

#include <NeonEngine.h>
#include <lua_macros.h>
#include <shellapi.h>

#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define ENET_IMPLEMENTATION
#include "enet.h"

#include <lua/lua.hpp>

#pragma comment (lib, "d3dx9.lib")

ENetHost *server = NULL;
ENetHost *client = NULL;
ENetPeer *client_peer = NULL;

INT tankupdateref = 0;
INT tankcollideref = 0;

#define DEBUG_LINES

static INT ne_server_start(lua_State* L) {
    if (server) {
        OutputDebugStringA("[server] Server is already running...\n");
        lua_pushnumber(L, -1);
        return 1;
    }

    ENetAddress address = {0};
    int port = luaL_checkinteger(L, 1);

    address.host = ENET_HOST_ANY; /* Bind the server to the default localhost.     */
    address.port = port; /* Bind the server to port . */

    /* create a server */
    server = enet_host_create(&address, 32, 2, 0, 0);

    if (server == NULL) {
        OutputDebugStringA("[server] An error occurred while trying to create an ENet server host.\n");
        lua_pushnumber(L, -1);
        return 1;
    }

    OutputDebugStringA("[server] Started an ENet server...\n");
    lua_pushnumber(L, 1);
    return 1;
}

static INT ne_server_stop(lua_State* L) {
    if (!server) {
        lua_pushnumber(L, -1);
        return 1;
    }

    enet_host_destroy(server);
    server = NULL;

    lua_pushnumber(L, 1);
    return 1;
}

static INT ne_connect(lua_State* L) {
    if (client || client_peer) {
        OutputDebugStringA("[client] You are already connected, disconnect first\n");
        lua_pushnumber(L, -1);
        return 1;
    }

    const char* hoststr = luaL_checkstring(L, 1);
    int port = luaL_checkinteger(L, 2);

    ENetAddress address = {0}; address.port = port;
    enet_address_set_host(&address, hoststr);

    client = enet_host_create(NULL, 1, 2, 0, 0);
    client_peer = enet_host_connect(client, &address, 2, 0);

    if (client_peer == NULL) {
        OutputDebugStringA("[client] Cannot connect\n");
        lua_pushnumber(L, -1);
        return 1;
    }

    lua_pushnumber(L, 1);
    return 1;
}

static INT ne_disconnect(lua_State* L) {
    if (!client || !client_peer) {
        lua_pushnumber(L, -1);
        return 1;
    }

    enet_peer_disconnect_now(client_peer, 0);
    enet_host_destroy(client);

    client_peer = NULL;
    client = NULL;

    lua_pushnumber(L, 1);
    return 1;
}

#define MAX_TRAILS 140

typedef struct {
    float x, y, z;
} ne_vec3;

typedef struct {
    float x, y, z, r;
    int c;
    ne_vec3 tail[MAX_TRAILS];
    int tail_end;
    float collision_delay;
    ENetPeer* peer;
} ne_data;

std::unordered_map<uint64_t, ne_data> ne_server_data;

float ne_check_collision_solve(float b, float dis) {
    float t;

    t = (-b - ::sqrtf(dis));
    if (t > 0) return t;

    t = (-b + ::sqrtf(dis));
    if (t > 0) return t;

    return -1.0f;
}

bool ne_check_collision(ne_vec3 p1, ne_vec3 p2, float cx, float cy, float cz) {
    D3DXVECTOR3 A = D3DXVECTOR3(p1.x, p1.y, p1.z);
    D3DXVECTOR3 B = D3DXVECTOR3(p2.x, p2.y, p2.z);
    D3DXVECTOR3 C = D3DXVECTOR3(cx, cy, cz);

    float r = 36.f;
    D3DXVECTOR3 d;
    D3DXVECTOR3 AB = (B-A);
    D3DXVec3Normalize(&d, &AB);

    D3DXVECTOR3 oc = (A-C);

    float a = D3DXVec3Dot(&d, &d);
    float b = 2 * D3DXVec3Dot(&d, &oc);
    float c = D3DXVec3Dot(&oc, &oc) - r;

    float dis = b * b - 4 * a * c;

    if (dis < 0) {
        return false;
    }

    float t = ne_check_collision_solve(b, dis) / (a * 2);

    auto dt = d*t;
    return (t > 0 && D3DXVec3LengthSq(&dt) < D3DXVec3LengthSq(&AB));


    // auto f = l - c;
    // return D3DXVec3LengthSq(&f) < (r * r);
    /*
    #define sq(a) (a*a)
    auto f = o - c;
    float delta = sq(D3DXVec3Dot(&l, &f)) - (D3DXVec3LengthSq(&f) - sq(r));
    auto t = std::string("delta: "); t += std::to_string(delta);
    OutputDebugStringA(t.c_str());
    return delta >= 0;
    #undef sq*/
}

void ne_server_update(lua_State* L) {
    ENetEvent event = {0};
    while (enet_host_service(server, &event, 2) > 0) {
        switch (event.type) {
            case ENET_EVENT_TYPE_CONNECT: {
                OutputDebugStringA("[server] A new user connected.\n");
                uint16_t entity_id = event.peer->incomingPeerID;

                /* allocate and store entity data in the data part of peer */
                ne_data _ent = { 0 }; _ent.peer = event.peer;
                ne_server_data[entity_id] = _ent;
                ne_server_data[entity_id].c = rand() % 360;

                char buffer[512] = { 0 };
                *((uint16_t*)(buffer)+0) = 4;
                *((uint16_t*)(buffer)+1) = (uint16_t)ne_server_data[entity_id].c;

                /* create packet with actual length, and send it */
                ENetPacket* packet = enet_packet_create(buffer, sizeof(uint16_t)*2, ENET_PACKET_FLAG_RELIABLE);
                enet_peer_send(event.peer, 0, packet);
                enet_peer_timeout(event.peer, 10, 5000, 10000);

            } break;
            case ENET_EVENT_TYPE_DISCONNECT:
            case ENET_EVENT_TYPE_DISCONNECT_TIMEOUT: {
                OutputDebugStringA("[server]  A user disconnected.\n");
                uint16_t entity_id = event.peer->incomingPeerID;

                ne_server_data.erase(entity_id);
            } break;

            case ENET_EVENT_TYPE_RECEIVE: {
                /* handle a newly received event */
                uint16_t entity_id = event.peer->incomingPeerID;
                char *buffer = (char *)event.packet->data;
                int offset = 0;

                if (ne_server_data[entity_id].x != 0) {
                    ne_vec3 pos = {ne_server_data[entity_id].x, ne_server_data[entity_id].y, ne_server_data[entity_id].z};
                    ne_server_data[entity_id].tail_end = (ne_server_data[entity_id].tail_end+1) % MAX_TRAILS;
                    ne_server_data[entity_id].tail[ne_server_data[entity_id].tail_end] = pos;
                }

                float x = *(float*)(buffer + offset); offset += sizeof(float);
                float y = *(float*)(buffer + offset); offset += sizeof(float);
                float z = *(float*)(buffer + offset); offset += sizeof(float);
                float r = *(float*)(buffer + offset); offset += sizeof(float);

                ne_server_data[entity_id].x = x;
                ne_server_data[entity_id].y = y;
                ne_server_data[entity_id].z = z;
                ne_server_data[entity_id].r = r;

                /* Clean up the packet now that we're done using it. */
                enet_packet_destroy(event.packet);
            } break;

            case ENET_EVENT_TYPE_NONE: break;
        }
    }

    /* check collisions */
    for (auto it = ne_server_data.begin(); it != ne_server_data.end(); ++it) {
        uint16_t entity_id = it->first;
        ne_data *data = &it->second;
        uint16_t killer_id = -1;
        bool collided = false;

        for (auto it2 = ne_server_data.begin(); it2 != ne_server_data.end() && !collided; ++it2) {
            if (entity_id == it2->first) continue;

            int tail = it2->second.tail_end < 0 ? MAX_TRAILS : it2->second.tail_end;
            for (int i = 0, s = tail; i < MAX_TRAILS; ++i) {
                s = (s-1) < 0 ? MAX_TRAILS-1 : s-1;
                int index_pre = s-1 < 0 ? MAX_TRAILS-1 : s-1;
                if (ne_check_collision(it2->second.tail[index_pre], it2->second.tail[s], data->x, data->y, data->z)) {
                    collided = true;
                    killer_id = it2->first;
                    data->collision_delay = GetTime() + 8.0f;
                    break;
                }
            }
        }

        if (collided) {
            char buffer[512] = { 0 };
            *((uint16_t*)(buffer)+0) = 2;
            *((uint16_t*)(buffer)+1) = killer_id;

            /* create packet with actual length, and send it */
            ENetPacket* packet = enet_packet_create(buffer, sizeof(uint16_t)*2, ENET_PACKET_FLAG_RELIABLE);
            enet_peer_send(data->peer, 0, packet);

            ENetPeer *currentPeer;
            for (currentPeer = server->peers; currentPeer < &server->peers[server->peerCount]; ++currentPeer) {
                if (currentPeer->state != ENET_PEER_STATE_CONNECTED && currentPeer != data->peer) {
                    continue;
                }

                int offset = sizeof(uint32_t);
                int count = 0;
                char buffer[512] = {0};

                *((uint16_t*)(buffer)+0) = 3;
                *((uint16_t*)(buffer)+1) = killer_id;
                *((uint16_t*)(buffer)+2) = entity_id;

                /* create packet with actual length, and send it */
                ENetPacket *packet = enet_packet_create(buffer, sizeof(uint16_t)*3, ENET_PACKET_FLAG_RELIABLE);
                enet_peer_send(currentPeer, 0, packet);
            }
        }
    }

    // static float last_send = 0;
    // float diff_send = GetTime() - last_send;
    // last_send = GetTime();

    // /* every 030 ms */
    // if (diff_send < 0.030) { return; }

    /* iterate peers and send them updates */
    ENetPeer *currentPeer;
    for (currentPeer = server->peers; currentPeer < &server->peers[server->peerCount]; ++currentPeer) {
        if (currentPeer->state != ENET_PEER_STATE_CONNECTED) {
            continue;
        }

        int offset = sizeof(uint32_t);
        int count = 0;
        char buffer[4096] = {0};

        for (auto it = ne_server_data.begin(); it != ne_server_data.end(); ++it) {
            // if (currentPeer->incomingPeerID == it->first) continue; /* skip sending to local player */

            *(uint16_t*)(buffer + offset) = it->first; offset += sizeof(uint16_t);
            *(float*)(buffer + offset) = it->second.x; offset += sizeof(float);
            *(float*)(buffer + offset) = it->second.y; offset += sizeof(float);
            *(float*)(buffer + offset) = it->second.z; offset += sizeof(float);
            *(float*)(buffer + offset) = it->second.r; offset += sizeof(float);
            *(uint16_t*)(buffer + offset) = it->second.c; offset += sizeof(uint16_t);
            *(uint8_t*)(buffer + offset) = (currentPeer->incomingPeerID == it->first); offset += sizeof(uint8_t);

#ifdef DEBUG_LINES
            int tail = it->second.tail_end < 0 ? MAX_TRAILS : it->second.tail_end;
            for (int i = 0, s = tail; i < MAX_TRAILS; ++i) {
                s = (s-1) < 0 ? MAX_TRAILS-1 : s-1;
                *(float*)(buffer + offset) = it->second.tail[s].x; offset += sizeof(float);
                *(float*)(buffer + offset) = it->second.tail[s].y; offset += sizeof(float);
                *(float*)(buffer + offset) = it->second.tail[s].z; offset += sizeof(float);
            }
#endif
            count++;
        }

        *((uint16_t*)(buffer)+0) = 1;
        *((uint16_t*)(buffer)+1) = count;

        if (offset > 0) {
            /* create packet with actual length, and send it */
            ENetPacket *packet = enet_packet_create(buffer, offset, ENET_PACKET_FLAG_RELIABLE);
            enet_peer_send(currentPeer, 0, packet);
        }
    }
}

void ne_client_update(lua_State* L) {
    ENetEvent event = {0};

    ENetPeer *peer = client_peer;
    ENetHost *host = client;

    while (enet_host_service(host, &event, 2) > 0) {
        switch (event.type) {
            case ENET_EVENT_TYPE_CONNECT: {
                OutputDebugStringA("[client] We connected to the server.\n");
            } break;
            case ENET_EVENT_TYPE_DISCONNECT:
            case ENET_EVENT_TYPE_DISCONNECT_TIMEOUT: {
                OutputDebugStringA("[client] We disconnected from server.\n");
            } break;

            case ENET_EVENT_TYPE_RECEIVE: {
                /* handle a newly received event */
                int offset = 0;
                char *buffer = (char *)event.packet->data;
                int packetid = *((uint16_t*)(buffer)+0);

                if (packetid == 1) {
                    int count = *((uint16_t*)(buffer)+1); offset += sizeof(uint32_t);

                    for (int i = 0; i < count; ++i) {
                        uint16_t entity_id = *(uint16_t*)(buffer + offset); offset += sizeof(uint16_t);
                        float x = *(float*)(buffer + offset); offset += sizeof(float);
                        float y = *(float*)(buffer + offset); offset += sizeof(float);
                        float z = *(float*)(buffer + offset); offset += sizeof(float);
                        float r = *(float*)(buffer + offset); offset += sizeof(float);
                        uint16_t c = *(uint16_t*)(buffer + offset); offset += sizeof(uint16_t);
                        uint8_t islocal = *(uint8_t*)(buffer + offset); offset += sizeof(uint8_t);

                        // OutputDebugStringA(CString::Format("update: %ld: [%f %f %f] %f %d\n", entity_id, x, y, z, r, c).Str());

                        lua_rawgeti(L, LUA_REGISTRYINDEX, tankupdateref);
                        lua_pushvalue(L, 1);

                        if (!lua_isfunction(L, -1))
                            goto ne_srv_clenaup;

                        lua_pushnumber(L, entity_id);
                        lua_pushnumber(L, x);
                        lua_pushnumber(L, y);
                        lua_pushnumber(L, z);
                        lua_pushnumber(L, r);
                        lua_pushnumber(L, c);
                        lua_pushnumber(L, islocal);

#ifdef DEBUG_LINES
                        lua_newtable(L);

                        for (int k = 0; k < MAX_TRAILS; ++k) {
                            float x = *(float*)(buffer + offset); offset += sizeof(float);
                            float y = *(float*)(buffer + offset); offset += sizeof(float);
                            float z = *(float*)(buffer + offset); offset += sizeof(float);

                            lua_pushinteger(L, k+1);
                            lua_newtable(L);

                            lua_pushinteger(L, 1);
                            lua_pushnumber(L, x);
                            lua_settable(L, -3);

                            lua_pushinteger(L, 2);
                            lua_pushnumber(L, y);
                            lua_settable(L, -3);

                            lua_pushinteger(L, 3);
                            lua_pushnumber(L, z);
                            lua_settable(L, -3);

                            lua_settable(L, -3);
                        }
#else
                        lua_pushnil(L);
#endif

                        lua_pcall(L, 8, 0, 0);

                        tankupdateref = luaL_ref(L, LUA_REGISTRYINDEX);
                    }
                }
                else if (packetid == 2) {
                    int killer_id = *((uint16_t*)(buffer)+1);

                    lua_rawgeti(L, LUA_REGISTRYINDEX, tankcollideref);
                    lua_pushvalue(L, 1);

                    if (!lua_isfunction(L, -1))
                        goto ne_srv_clenaup;

                    lua_pushnumber(L, killer_id);
                    lua_pushinteger(L, -1);
                    lua_pcall(L, 2, 0, 0);
                    tankcollideref = luaL_ref(L, LUA_REGISTRYINDEX);
                }
                else if (packetid == 3) {
                    int killer_id = *((uint16_t*)(buffer)+1);
                    int victim_id = *((uint16_t*)(buffer)+2);

                    lua_rawgeti(L, LUA_REGISTRYINDEX, tankcollideref);
                    lua_pushvalue(L, 1);

                    if (!lua_isfunction(L, -1))
                        goto ne_srv_clenaup;

                    lua_pushnumber(L, killer_id);
                    lua_pushnumber(L, victim_id);
                    lua_pcall(L, 2, 0, 0);
                    tankcollideref = luaL_ref(L, LUA_REGISTRYINDEX);
                }
                else if (packetid == 4) {
                    int color = *((uint16_t*)(buffer)+1);
                    OutputDebugStringA(CString::Format("setting my own color: %d\n", color).Str());
                    REGN(localPlayerColor, color);
                }
ne_srv_clenaup:
                /* Clean up the packet now that we're done using it. */
                enet_packet_destroy(event.packet);
            } break;

            case ENET_EVENT_TYPE_NONE: break;
        }
    }
}

static INT ne_update(lua_State* L) {
    if (server) ne_server_update(L);
    if (client) ne_client_update(L);
    lua_pushnumber(L, 1);
    return 1;
}

static INT ne_send(lua_State* L) {
    if (!client || !client_peer) {
        lua_pushnumber(L, -1);
        return 1;
    }

    /* send our data to the server */
    char buffer[256] = {0};
    size_t offset = 0;

    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    float z = luaL_checknumber(L, 3);
    float r = luaL_checknumber(L, 4);

    /* serialize peer's the world view to a buffer */
    *(float*)(buffer + offset) = x; offset += sizeof(float);
    *(float*)(buffer + offset) = y; offset += sizeof(float);
    *(float*)(buffer + offset) = z; offset += sizeof(float);
    *(float*)(buffer + offset) = r; offset += sizeof(float);

    /* create packet with actual length, and send it */
    ENetPacket *packet = enet_packet_create(buffer, offset, ENET_PACKET_FLAG_RELIABLE);
    enet_peer_send(client_peer, 0, packet);

    lua_pushnumber(L, 1);
    return 1;
}

static INT ne_setupdate(lua_State* L) {
    tankupdateref = luaL_ref(L, LUA_REGISTRYINDEX);
    return 0;
}

static INT ne_setcollide(lua_State* L) {
    tankcollideref = luaL_ref(L, LUA_REGISTRYINDEX);
    return 0;
}

static INT ne_openlink(lua_State *L) {
    ShellExecuteA(0, 0, "https://discord.gg/eBQ4QHX", 0, 0 , SW_SHOW);
    return 0;
}

static const luaL_Reg networkplugin[] = {
    {"serverStart", ne_server_start},
    {"serverStop", ne_server_stop},
    {"connect", ne_connect},
    {"disconnect", ne_disconnect},
    {"update", ne_update},
    {"send", ne_send},
    {"setUpdate", ne_setupdate},
    {"setCollide", ne_setcollide},
    {"openLink", ne_openlink},
    ENDF
};

extern "C" INT PLUGIN_API luaopen_linesnetworking(lua_State* L) {
    srand(time(NULL));
    enet_initialize();
    luaL_newlib(L, networkplugin);
    return 1;
}

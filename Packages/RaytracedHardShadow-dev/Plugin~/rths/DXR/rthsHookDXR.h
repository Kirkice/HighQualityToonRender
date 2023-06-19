#pragma once

namespace rths {

using OnBufferUpdateT = std::function<void(void*)>;
using OnBufferReleaseT = std::function<void(void*)>;
using OnTextureReleaseT = std::function<void(void*)>;

void SetOnBufferUpdate(const OnBufferUpdateT& v);
void SetOnBufferRelease(const OnBufferReleaseT& v);
void SetOnTextureRelease(const OnTextureReleaseT& v);
void ClearResourceCallbacks();

// T: ID3D11DeviceContext, ID3D11Buffer
template<class T>
bool InstallHook(T *dst);

} // namespace rths

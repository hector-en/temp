et -euo pipefail

SRC_DIR="/c/Users/hector/documents/scripting/tools/app"
DST_DIR="$HOME/chatgpt_temp/tools/patches"

mkdir -p "$DST_DIR"

MOVED_PATCHES=()

if [ "$#" -gt 0 ]; then
	    for arg in "$@"; do
		            if [[ "$arg" = /* || "$arg" = ./* || "$arg" = ../* ]]; then
				                patch_path="$arg"
						        else
								            patch_path="$DST_DIR/$arg"
									            fi

										            if [ ! -f "$patch_path" ]; then
												                echo "Missing patch file: $patch_path" >&2
														            exit 1
															            fi

																            MOVED_PATCHES+=("$patch_path")
																	        done
																	else
																		    mapfile -t PATCH_PATHS < <(
																		            find "$SRC_DIR" -type f -name '*.patch' | sort
																			        )

																				    if [ "${#PATCH_PATHS[@]}" -eq 0 ]; then
																					            echo "No patch files found under $SRC_DIR"
																						            exit 0
																							        fi

																								    for src_path in "${PATCH_PATHS[@]}"; do
																									            patch_name="$(basename "$src_path")"
																										            dst_path="$DST_DIR/$patch_name"

																											            mv "$src_path" "$dst_path"
																												            MOVED_PATCHES+=("$dst_path")
																													        done
fi

sudo chown vmuser:vmuser "${MOVED_PATCHES[@]}"
chmod +x "${MOVED_PATCHES[@]}"

for patch_file in "${MOVED_PATCHES[@]}"; do
	    echo "=== Dry run: $patch_file ==="
	        patch --dry-run -p1 < "$patch_file"
		    echo
	    done

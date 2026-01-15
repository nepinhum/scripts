#!/usr/bin/env bash

DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR" || exit 1

while getopts "p:f:l" OPTION 2> /dev/null; do
	case ${OPTION} in
		p)
			PHP_BINARY="$OPTARG"
			;;
		f)
			AQUARELAY_FILE="$OPTARG"
			;;
		l)
			DO_LOOP="yes"
			;;
		\?)
			break
			;;
	esac
done

if [ -z "$PHP_BINARY" ]; then
	if [ -f ./bin/php/php ]; then
		export PHPRC=""
		PHP_BINARY="./bin/php/php"
	elif command -v php >/dev/null 2>&1; then
		PHP_BINARY="$(command -v php)"
	else
		echo "Couldn't find a PHP binary in system PATH or $PWD/bin/php"
		echo "Please download it from https://github.com/pmmp/PHP-Binaries/releases"
		exit 1
	fi
fi

if [ -z "$AQUARELAY_FILE" ]; then
	if [ -f ./AquaRelay.phar ]; then
		AQUARELAY_FILE="./AquaRelay.phar"
	elif [ -f ./src/AquaRelay.php ]; then
		AQUARELAY_FILE="./src/AquaRelay.php"
	else
		echo "AquaRelay not found"
		echo "Please download it from https://github.com/AquaRelay/AquaRelay/releases"
		exit 1
	fi
fi

LOOPS=0
set +e

handle_exit_code() {
	local exitcode=$1

	if [ "$exitcode" -eq 134 ] || [ "$exitcode" -eq 139 ]; then
		echo ""
		echo "ERROR: AquaRelay crashed due to a critical PHP error (code $exitcode)."
		echo "Updating your PHP binary is recommended."
		echo ""
	elif [ "$exitcode" -eq 143 ]; then
		echo ""
		echo "WARNING: AquaRelay was forcibly killed!"
		echo ""
	elif [ "$exitcode" -ne 0 ] && [ "$exitcode" -ne 137 ]; then
		echo ""
		echo "WARNING: AquaRelay did not shut down cleanly! (code $exitcode)"
		echo ""
	fi
}

if [ "$DO_LOOP" == "yes" ]; then
	while true; do
		if [ $LOOPS -gt 0 ]; then
			echo "Restarted $LOOPS times"
		fi

		"$PHP_BINARY" "$AQUARELAY_FILE" "$@"
		handle_exit_code $?

		echo "To stop restarting, press CTRL+C now. Restarting in 5 seconds..."
		echo ""
		sleep 5
		((LOOPS++))
	done
else
	"$PHP_BINARY" "$AQUARELAY_FILE" "$@"
	exitcode=$?
	handle_exit_code $exitcode
	exit $exitcode
fi

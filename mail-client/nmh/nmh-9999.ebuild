# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"


DESCRIPTION="New MH mail reader"
HOMEPAGE="http://www.nongnu.org/nmh/"

if [ "${PV#9999}" != "${PV}" ] ; then
	SCM="git-r3"
	EGIT_REPO_URI="git://git.savannah.nongnu.org/nmh.git"
fi

inherit eutils ${SCM}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gdbm tls oauth sasl"

DEPEND="gdbm? ( sys-libs/gdbm )
	!gdbm? ( sys-libs/db )
	>=sys-libs/ncurses-5.2
	net-libs/liblockfile
	>=app-misc/editor-wrapper-3
	!!media-gfx/pixie" # Bug #295996 media-gfx/pixie also uses show
RDEPEND="${DEPEND}"

DOCS=( ChangeLog DATE MACHINES README )


src_configure() {
	# Bug 348816 & Bug 341741: The previous ebuild default of
	# /usr/bin caused unnecessary conflicts with other
	# packages. However, the default nmh libdir location causes
	# problems with cross-compiling, so we use, eg., /usr/lib64.
	# Users may use /usr/lib/nmh in scripts needing these support
	# programs in normal environments.
	local myconf="--libdir=/usr/$(get_libdir)/nmh"

	# Have gdbm use flag actually control which version of db in use
	if use gdbm; then
		myconf="${myconf} --with-ndbmheader=gdbm/ndbm.h --with-ndbm=gdbm_compat"
	else
		if has_version ">=sys-libs/db-2"; then
			myconf="${myconf} --with-ndbmheader=db.h --with-ndbm=db"
		else
			myconf="${myconf} --with-ndbmheader=db1/ndbm.h --with-ndbm=db1"
		fi
	fi
	if use sasl; then
		myconf="${myconf} --with-curus-sasl"
	fi
	if use tls; then
		myconf="{myconf} --with-tls"
	fi
	if use oauth; then
		myconf="{myconf} --with-oauth"
	fi

	./autogen.sh
	econf \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--sysconfdir=/etc \
		${myconf}
}

src_compile() {
	emake all ChangeLog
}

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/images/t_circular_image.dart';
import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: const TAppBar(
        title: Text('Profile'),
        showBackArrow: true,
      ),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const TCircularImage(image: TImages.user, width: 80, height: 80,),
                    TextButton(onPressed: (){}, child: const Text('Ubah'))
                  ],
                ),
              ),

              // Heading Profile Info
              const SizedBox(height: TSizes.spaceBtwItems / 2,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

             
              TProfileMenu(title: 'Nama', value: 'Galang Rahmad Dhani', onPressed: () {},),
              TProfileMenu(title: 'Username', value: 'galangtampan_123', onPressed: () {},),

              const SizedBox(height: TSizes.spaceBtwItems,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              // Heading Personal Info
              const TSectionHeading(title: 'Informasi Profil', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems,),

              TProfileMenu(title: 'User ID', value: '2378923', icon: Iconsax.copy, onPressed: () {},),
              TProfileMenu(title: 'E-mail', value: 'galangamd@gmail.com', onPressed: () {},),
              TProfileMenu(title: 'No. Telp', value: '+62-821-4078-4672', onPressed: () {},),
              TProfileMenu(title: 'Jns Kelamin', value: 'Laki-laki', onPressed: () {},),
              TProfileMenu(title: 'Tgl Lahir', value: '18 Okt, 2006', onPressed: () {},),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems,),

              Center(
                child: TextButton(
                  onPressed: (){}, 
                  child: const Text('logout', style: TextStyle(color: Colors.red),)
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}